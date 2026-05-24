<?php

namespace App\Services\Auth;

use App\Models\SocialAccount;
use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class GoogleOAuthService
{
    private const PROVIDER = 'google';

    private const STATE_PREFIX = 'google_oauth_state:';

    public function authorizationUrl(string $purpose = 'login', ?int $userId = null): string
    {
        $clientId = $this->clientId();
        $state = Str::random(48);

        Cache::put(self::STATE_PREFIX.$state, [
            'purpose' => $purpose,
            'user_id' => $userId,
        ], now()->addMinutes(10));

        return 'https://accounts.google.com/o/oauth2/v2/auth?'.http_build_query([
            'client_id' => $clientId,
            'redirect_uri' => $this->redirectUri(),
            'response_type' => 'code',
            'scope' => 'openid email profile',
            'state' => $state,
            'prompt' => 'select_account',
            'access_type' => 'online',
        ], '', '&', PHP_QUERY_RFC3986);
    }

    /**
     * @return array{user: User, purpose: string}
     */
    public function handleCallback(Request $request): array
    {
        if ($request->filled('error')) {
            throw new GoogleOAuthException('Google sign-in was cancelled or denied.');
        }

        $state = (string) $request->query('state', '');
        $cachedState = Cache::pull(self::STATE_PREFIX.$state);

        if (! is_array($cachedState)) {
            throw new GoogleOAuthException('Google sign-in state is invalid or expired.');
        }

        $code = (string) $request->query('code', '');

        if ($code === '') {
            throw new GoogleOAuthException('Google did not return an authorization code.');
        }

        $profile = $this->fetchProfile($code);
        $purpose = (string) ($cachedState['purpose'] ?? 'login');

        if ($purpose === 'link') {
            $user = User::query()->find($cachedState['user_id'] ?? null);

            if (! $user) {
                throw new GoogleOAuthException('The account linking session is invalid or expired.');
            }

            return [
                'user' => $this->linkGoogleAccount($user, $profile),
                'purpose' => 'link',
            ];
        }

        return [
            'user' => $this->resolveLogin($profile),
            'purpose' => 'login',
        ];
    }

    /**
     * @param  array{sub: string, email: string, email_verified: bool, name: string|null}  $profile
     */
    private function resolveLogin(array $profile): User
    {
        return DB::transaction(function () use ($profile): User {
            $linkedAccount = SocialAccount::query()
                ->where('provider', self::PROVIDER)
                ->where('provider_user_id', $profile['sub'])
                ->first();

            if ($linkedAccount) {
                return $linkedAccount->user;
            }

            if ($profile['email_verified']) {
                $existingUser = User::query()
                    ->where('email', $profile['email'])
                    ->first();

                if ($existingUser) {
                    return $this->linkGoogleAccount($existingUser, $profile);
                }
            }

            $fallbackName = $profile['name']
                ?: Str::of($profile['email'])->before('@')->replace(['.', '_', '-'], ' ')->title()->toString();

            $user = User::query()->create([
                'name' => $fallbackName,
                'email' => $profile['email'],
                'email_verified_at' => $profile['email_verified'] ? now() : null,
                'password' => Hash::make(Str::random(40)),
            ]);

            UserProfile::query()->create([
                'user_id' => $user->id,
                'full_name' => null,
            ]);

            return $this->linkGoogleAccount($user, $profile);
        });
    }

    /**
     * @param  array{sub: string, email: string, email_verified: bool, name: string|null}  $profile
     */
    private function linkGoogleAccount(User $user, array $profile): User
    {
        $existingAccount = SocialAccount::query()
            ->where('provider', self::PROVIDER)
            ->where('provider_user_id', $profile['sub'])
            ->first();

        if ($existingAccount) {
            if ((int) $existingAccount->user_id !== (int) $user->id) {
                throw new GoogleOAuthException('This Google account is already linked to another user.');
            }

            return $user;
        }

        $existingProviderForUser = SocialAccount::query()
            ->where('user_id', $user->id)
            ->where('provider', self::PROVIDER)
            ->first();

        if ($existingProviderForUser) {
            throw new GoogleOAuthException('This user already has a linked Google account.');
        }

        SocialAccount::query()->create([
            'user_id' => $user->id,
            'provider' => self::PROVIDER,
            'provider_user_id' => $profile['sub'],
            'provider_email' => $profile['email'],
        ]);

        return $user;
    }

    /**
     * @return array{sub: string, email: string, email_verified: bool, name: string|null}
     */
    private function fetchProfile(string $code): array
    {
        $tokenResponse = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'code' => $code,
            'client_id' => $this->clientId(),
            'client_secret' => $this->clientSecret(),
            'redirect_uri' => $this->redirectUri(),
            'grant_type' => 'authorization_code',
        ]);

        if (! $tokenResponse->successful()) {
            throw new GoogleOAuthException('Google token exchange failed.');
        }

        $idToken = $tokenResponse->json('id_token');

        if (! is_string($idToken) || $idToken === '') {
            throw new GoogleOAuthException('Google did not return an ID token.');
        }

        $tokenInfoResponse = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if (! $tokenInfoResponse->successful()) {
            throw new GoogleOAuthException('Google ID token verification failed.');
        }

        $tokenInfo = $tokenInfoResponse->json();

        if (! is_array($tokenInfo) || ($tokenInfo['aud'] ?? null) !== $this->clientId()) {
            throw new GoogleOAuthException('Google ID token audience is invalid.');
        }

        $sub = $tokenInfo['sub'] ?? null;
        $email = $tokenInfo['email'] ?? null;

        if (! is_string($sub) || $sub === '' || ! is_string($email) || $email === '') {
            throw new GoogleOAuthException('Google account profile is incomplete.');
        }

        return [
            'sub' => $sub,
            'email' => $email,
            'email_verified' => filter_var($tokenInfo['email_verified'] ?? false, FILTER_VALIDATE_BOOL),
            'name' => is_string($tokenInfo['name'] ?? null) ? $tokenInfo['name'] : null,
        ];
    }

    private function clientId(): string
    {
        $clientId = config('services.google.client_id');

        if (! is_string($clientId) || $clientId === '') {
            throw new GoogleOAuthException('Google OAuth client ID is not configured.');
        }

        return $clientId;
    }

    private function clientSecret(): string
    {
        $clientSecret = config('services.google.client_secret');

        if (! is_string($clientSecret) || $clientSecret === '') {
            throw new GoogleOAuthException('Google OAuth client secret is not configured.');
        }

        return $clientSecret;
    }

    private function redirectUri(): string
    {
        return rtrim((string) config('app.url'), '/').'/api/auth/google/callback';
    }
}
