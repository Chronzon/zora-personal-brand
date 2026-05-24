<?php

namespace Tests\Feature;

use App\Models\SocialAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class GoogleAuthFeatureTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('app.url', 'http://localhost:8000');
        config()->set('services.frontend.url', 'http://localhost:8080');
        config()->set('services.google.client_id', 'google-web-client-id');
        config()->set('services.google.client_secret', 'google-client-secret');
    }

    public function test_google_redirect_sends_user_to_google_with_expected_callback(): void
    {
        $response = $this->get('/api/auth/google/redirect');

        $response->assertRedirect();

        $location = $response->headers->get('Location');
        $this->assertIsString($location);
        $this->assertStringStartsWith('https://accounts.google.com/o/oauth2/v2/auth?', $location);

        parse_str((string) parse_url($location, PHP_URL_QUERY), $query);

        $this->assertSame('google-web-client-id', $query['client_id']);
        $this->assertSame('http://localhost:8000/api/auth/google/callback', $query['redirect_uri']);
        $this->assertSame('code', $query['response_type']);
        $this->assertSame('openid email profile', $query['scope']);
        $this->assertNotEmpty($query['state']);
    }

    public function test_new_google_user_is_created_and_logged_in(): void
    {
        $callback = $this->performGoogleCallback([
            'sub' => 'google-sub-1',
            'email' => 'new-google@example.test',
            'email_verified' => 'true',
            'name' => 'New Google User',
        ]);

        $callback->assertRedirect();
        $location = $callback->headers->get('Location');
        $token = $this->extractAuthToken($location);

        $this->assertDatabaseHas('users', [
            'email' => 'new-google@example.test',
            'name' => 'New Google User',
        ]);
        $this->assertDatabaseHas('user_profiles', [
            'full_name' => null,
        ]);
        $this->assertDatabaseHas('social_accounts', [
            'provider' => 'google',
            'provider_user_id' => 'google-sub-1',
            'provider_email' => 'new-google@example.test',
        ]);

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('user.email', 'new-google@example.test');
    }

    public function test_verified_google_email_links_existing_password_user(): void
    {
        $register = $this->postJson('/api/register', [
            'email' => 'existing@example.test',
            'password' => 'password123',
            'full_name' => 'Existing App Name',
        ])->assertCreated();

        $userId = $register->json('user.id');

        $this->performGoogleCallback([
            'sub' => 'google-sub-existing',
            'email' => 'existing@example.test',
            'email_verified' => 'true',
            'name' => 'Google Account Name',
        ])->assertRedirect();

        $this->assertSame(1, User::query()->count());
        $this->assertDatabaseHas('users', [
            'id' => $userId,
            'email' => 'existing@example.test',
            'name' => 'Existing App Name',
        ]);
        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $userId,
            'full_name' => 'Existing App Name',
        ]);
        $this->assertDatabaseHas('social_accounts', [
            'user_id' => $userId,
            'provider' => 'google',
            'provider_user_id' => 'google-sub-existing',
        ]);
    }

    public function test_already_linked_google_account_logs_in_linked_user(): void
    {
        $user = User::factory()->create([
            'email' => 'linked@example.test',
            'name' => 'Linked User',
        ]);

        SocialAccount::query()->create([
            'user_id' => $user->id,
            'provider' => 'google',
            'provider_user_id' => 'linked-google-sub',
            'provider_email' => 'old-email@example.test',
        ]);

        $callback = $this->performGoogleCallback([
            'sub' => 'linked-google-sub',
            'email' => 'new-email@example.test',
            'email_verified' => 'true',
            'name' => 'New Google Name',
        ]);

        $token = $this->extractAuthToken($callback->headers->get('Location'));

        $this->assertSame(1, User::query()->count());

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('user.id', $user->id);
    }

    public function test_different_email_google_login_does_not_merge_existing_user(): void
    {
        $this->postJson('/api/register', [
            'email' => 'random@example.test',
            'password' => 'password123',
            'full_name' => 'Random Email User',
        ])->assertCreated();

        $this->performGoogleCallback([
            'sub' => 'different-email-sub',
            'email' => 'real-google@example.test',
            'email_verified' => 'true',
            'name' => 'Real Google User',
        ])->assertRedirect();

        $this->assertSame(2, User::query()->count());
        $this->assertDatabaseHas('users', ['email' => 'random@example.test']);
        $this->assertDatabaseHas('users', ['email' => 'real-google@example.test']);
    }

    public function test_linking_rejects_google_account_linked_to_another_user(): void
    {
        $owner = User::factory()->create(['email' => 'owner@example.test']);
        $other = User::factory()->create(['email' => 'other@example.test']);

        SocialAccount::query()->create([
            'user_id' => $owner->id,
            'provider' => 'google',
            'provider_user_id' => 'claimed-sub',
            'provider_email' => 'claimed@example.test',
        ]);

        $linkUrl = $this->withToken($this->issueTokenFor($other))
            ->postJson('/api/auth/google/link')
            ->assertOk()
            ->json('url');

        parse_str((string) parse_url($linkUrl, PHP_URL_QUERY), $query);

        Http::fake([
            'https://oauth2.googleapis.com/token' => Http::response(['id_token' => 'fake-id-token'], 200),
            'https://oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'google-web-client-id',
                'sub' => 'claimed-sub',
                'email' => 'claimed@example.test',
                'email_verified' => 'true',
                'name' => 'Claimed Account',
            ], 200),
        ]);

        $callback = $this->get('/api/auth/google/callback?'.http_build_query([
            'state' => $query['state'],
            'code' => 'fake-code',
        ]));

        $callback->assertRedirect();
        $this->assertStringContainsString('auth_error=', $callback->headers->get('Location'));
        $this->assertSame(1, SocialAccount::query()->count());
    }

    public function test_google_status_returns_connected_email_for_current_user(): void
    {
        $user = User::factory()->create(['email' => 'password@example.test']);
        SocialAccount::query()->create([
            'user_id' => $user->id,
            'provider' => 'google',
            'provider_user_id' => 'status-sub',
            'provider_email' => 'connected-google@example.test',
        ]);

        $this->withToken($this->issueTokenFor($user))
            ->getJson('/api/auth/google/status')
            ->assertOk()
            ->assertJsonPath('connected', true)
            ->assertJsonPath('email', 'connected-google@example.test');
    }

    public function test_google_status_returns_not_connected_for_current_user(): void
    {
        $user = User::factory()->create(['email' => 'password@example.test']);

        $this->withToken($this->issueTokenFor($user))
            ->getJson('/api/auth/google/status')
            ->assertOk()
            ->assertJsonPath('connected', false)
            ->assertJsonPath('email', null);
    }

    /**
     * @param  array{sub: string, email: string, email_verified: string, name: string}  $profile
     */
    private function performGoogleCallback(array $profile)
    {
        $redirect = $this->get('/api/auth/google/redirect');
        parse_str((string) parse_url($redirect->headers->get('Location'), PHP_URL_QUERY), $query);

        Http::fake([
            'https://oauth2.googleapis.com/token' => Http::response(['id_token' => 'fake-id-token'], 200),
            'https://oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'google-web-client-id',
                ...$profile,
            ], 200),
        ]);

        return $this->get('/api/auth/google/callback?'.http_build_query([
            'state' => $query['state'],
            'code' => 'fake-code',
        ]));
    }

    private function extractAuthToken(?string $location): string
    {
        $this->assertIsString($location);
        $this->assertStringStartsWith('http://localhost:8080/#auth-callback?', $location);

        parse_str((string) parse_url((string) parse_url($location, PHP_URL_FRAGMENT), PHP_URL_QUERY), $query);

        $this->assertArrayHasKey('auth_token', $query);

        return $query['auth_token'];
    }

    private function issueTokenFor(User $user): string
    {
        $token = 'plain-test-token-'.$user->id;
        $user->forceFill(['api_token' => hash('sha256', $token)])->save();

        return $token;
    }
}
