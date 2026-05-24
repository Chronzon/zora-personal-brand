<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_login_fetch_me_and_logout(): void
    {
        $register = $this->postJson('/api/register', [
            'email' => 'zora@example.test',
            'password' => 'password123',
            'full_name' => 'Zora Builder',
        ]);

        $register
            ->assertCreated()
            ->assertJsonStructure(['token', 'user' => ['id', 'email', 'name']])
            ->assertJsonMissingPath('user.password')
            ->assertJsonMissingPath('user.api_token');

        $this->assertDatabaseHas('users', ['email' => 'zora@example.test']);
        $this->assertDatabaseHas('user_profiles', ['full_name' => 'Zora Builder']);

        $login = $this->postJson('/api/login', [
            'email' => 'zora@example.test',
            'password' => 'password123',
        ]);

        $login
            ->assertOk()
            ->assertJsonStructure(['token', 'user' => ['id', 'email', 'name']]);

        $token = $login->json('token');

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('user.email', 'zora@example.test');

        $this->withToken($token)
            ->postJson('/api/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Logged out.');

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertUnauthorized();
    }

    public function test_profiles_can_be_saved_and_fetched(): void
    {
        $token = $this->registerToken('profile@example.test');

        $this->withToken($token)
            ->putJson('/api/user-profile', [
                'full_name' => 'Profile Owner',
                'what_i_love' => 'Teaching practical branding',
                'what_im_good_at' => 'Turning ideas into systems',
                'what_the_world_needs' => 'Clearer creator strategy',
                'what_i_can_be_paid_for' => 'Content consulting',
            ])
            ->assertOk()
            ->assertJsonPath('data.full_name', 'Profile Owner');

        $this->withToken($token)
            ->getJson('/api/user-profile')
            ->assertOk()
            ->assertJsonPath('data.what_i_love', 'Teaching practical branding');

        $this->withToken($token)
            ->putJson('/api/brand-profile', [
                'selected_profile_name' => 'Creator Strategy Lab',
                'selected_category' => 'Education',
                'selected_micro_niche' => 'Personal branding for beginners',
                'selected_premise' => 'Helping beginners build a practical brand.',
                'tone_of_voice' => 'Warm and practical',
                'target_audience' => 'New creators',
                'strengths' => 'Clarity',
                'weaknesses' => 'Overthinking',
                'opportunities' => 'Creator economy growth',
                'threats' => 'Generic advice',
                'monetization_options' => ['Paid workshops', 'Content audits'],
                'content_pillars' => ['Story', 'Tutorial', 'Q&A'],
            ])
            ->assertOk()
            ->assertJsonPath('data.monetization_options.0', 'Paid workshops')
            ->assertJsonPath('data.content_pillars.0', 'Story');

        $this->withToken($token)
            ->getJson('/api/brand-profile')
            ->assertOk()
            ->assertJsonPath('data.selected_profile_name', 'Creator Strategy Lab')
            ->assertJsonPath('data.monetization_options.1', 'Content audits')
            ->assertJsonPath('data.content_pillars.2', 'Q&A');
    }

    public function test_generated_scripts_are_user_scoped(): void
    {
        $ownerToken = $this->registerToken('owner@example.test');
        $otherToken = $this->registerToken('other@example.test');

        $ownerScript = $this->withToken($ownerToken)
            ->postJson('/api/generated-scripts', [
                'title' => 'Owner Script',
                'platform' => 'LinkedIn',
                'script' => 'Hook, body, CTA.',
                'original_idea_id' => 'idea-1',
                'pillar' => 'Tutorial',
            ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Owner Script');

        $scriptId = $ownerScript->json('data.id');

        $this->withToken($otherToken)
            ->postJson('/api/generated-scripts', [
                'title' => 'Other Script',
                'platform' => 'Instagram',
                'script' => 'Another script.',
                'pillar' => 'Story',
            ])
            ->assertCreated();

        $this->withToken($ownerToken)
            ->getJson('/api/generated-scripts')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Owner Script');

        $this->withToken($otherToken)
            ->deleteJson("/api/generated-scripts/{$scriptId}")
            ->assertNotFound();

        $this->assertDatabaseHas('generated_scripts', [
            'id' => $scriptId,
            'title' => 'Owner Script',
        ]);
    }

    public function test_invalid_token_is_rejected(): void
    {
        $this->withToken('invalid-token')
            ->getJson('/api/me')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Invalid token.');
    }

    public function test_string_and_array_validation_returns_422(): void
    {
        $token = $this->registerToken('validation@example.test');

        $this->withToken($token)
            ->postJson('/api/generated-scripts', [
                'title' => str_repeat('a', 256),
                'platform' => 'LinkedIn',
                'script' => 'Valid script body.',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['title']);

        $ideas = array_fill(0, 51, [
            'title' => 'Idea',
            'platform' => 'Multi-Platform',
        ]);

        $this->withToken($token)
            ->postJson('/api/content-ideas', [
                'pillar' => 'Tutorial',
                'ideas' => $ideas,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['ideas']);

        $this->withToken($token)
            ->putJson('/api/brand-profile', [
                'selected_profile_name' => str_repeat('b', 256),
                'monetization_options' => ['Valid', str_repeat('m', 256)],
                'content_pillars' => ['Valid', str_repeat('c', 256)],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'selected_profile_name',
                'monetization_options.1',
                'content_pillars.1',
            ]);
    }

    private function registerToken(string $email): string
    {
        $response = $this->postJson('/api/register', [
            'email' => $email,
            'password' => 'password123',
            'full_name' => 'Test User',
        ]);

        $response->assertCreated();

        return $response->json('token');
    }
}
