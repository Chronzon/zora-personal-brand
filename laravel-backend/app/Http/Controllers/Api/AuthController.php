<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SocialAccount;
use App\Models\User;
use App\Models\UserProfile;
use App\Services\Auth\GoogleOAuthException;
use App\Services\Auth\GoogleOAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Throwable;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'max:255'],
            'full_name' => ['required', 'string', 'max:255'],
        ]);

        $plainToken = Str::random(80);

        $user = DB::transaction(function () use ($data, $plainToken): User {
            $user = User::query()->create([
                'name' => $data['full_name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'api_token' => hash('sha256', $plainToken),
            ]);

            UserProfile::query()->create([
                'user_id' => $user->id,
                'full_name' => $data['full_name'],
            ]);

            return $user;
        });

        return $this->authResponse($user, $plainToken, 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'max:255'],
        ]);

        $user = User::query()->where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $plainToken = Str::random(80);
        $user->forceFill(['api_token' => hash('sha256', $plainToken)])->save();

        return $this->authResponse($user, $plainToken);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(['user' => $request->user()]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->forceFill(['api_token' => null])->save();

        return response()->json(['message' => 'Logged out.']);
    }

    public function googleRedirect(GoogleOAuthService $googleOAuth): RedirectResponse
    {
        try {
            return redirect()->away($googleOAuth->authorizationUrl());
        } catch (Throwable $exception) {
            Log::error('Google OAuth redirect failed.', [
                'message' => $exception->getMessage(),
            ]);

            return $this->frontendRedirect([
                'auth_error' => 'Google sign-in is not configured correctly.',
            ]);
        }
    }

    public function googleCallback(Request $request, GoogleOAuthService $googleOAuth): RedirectResponse
    {
        try {
            $result = $googleOAuth->handleCallback($request);
            $plainToken = $this->issueToken($result['user']);

            return $this->frontendRedirect([
                'auth_token' => $plainToken,
                'google_auth' => $result['purpose'] === 'link' ? 'linked' : 'success',
            ]);
        } catch (GoogleOAuthException $exception) {
            return $this->frontendRedirect([
                'auth_error' => $exception->getMessage(),
            ]);
        } catch (Throwable $exception) {
            Log::error('Google OAuth callback failed.', [
                'message' => $exception->getMessage(),
            ]);

            return $this->frontendRedirect([
                'auth_error' => 'Google sign-in failed. Please try again.',
            ]);
        }
    }

    public function googleLinkRedirect(Request $request, GoogleOAuthService $googleOAuth): JsonResponse
    {
        return response()->json([
            'url' => $googleOAuth->authorizationUrl('link', $request->user()->id),
        ]);
    }

    public function googleStatus(Request $request): JsonResponse
    {
        $account = SocialAccount::query()
            ->where('user_id', $request->user()->id)
            ->where('provider', 'google')
            ->first();

        return response()->json([
            'connected' => $account !== null,
            'email' => $account?->provider_email,
        ]);
    }

    private function authResponse(User $user, string $token, int $status = 200): JsonResponse
    {
        return response()->json([
            'token' => $token,
            'user' => $user,
        ], $status);
    }

    private function issueToken(User $user): string
    {
        $plainToken = Str::random(80);
        $user->forceFill(['api_token' => hash('sha256', $plainToken)])->save();

        return $plainToken;
    }

    private function frontendRedirect(array $params): RedirectResponse
    {
        $frontendUrl = rtrim((string) config('services.frontend.url'), '/');
        $fragment = 'auth-callback?'.http_build_query($params, '', '&', PHP_QUERY_RFC3986);

        return redirect()->away($frontendUrl.'/#'.$fragment);
    }
}
