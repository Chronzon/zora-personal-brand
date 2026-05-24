<?php

namespace Tests\Feature;

use App\Services\Ai\AiClientInterface;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AiProcessFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_process_ai_uses_local_provider_with_existing_response_shape(): void
    {
        config(['services.ai.provider' => 'local']);
        $this->app->forgetInstance(AiClientInterface::class);

        $token = $this->registerToken('ai-local@example.test');

        $this->withToken($token)
            ->postJson('/api/process-ai', [
                'action' => 'generate_identity',
                'payload' => [
                    'fullName' => 'Zora',
                    'whatILove' => 'Teaching',
                ],
                'language' => 'id',
            ])
            ->assertOk()
            ->assertJsonStructure(['result'])
            ->assertJsonPath('result', fn ($result) => is_string($result)
                && str_contains($result, 'Zora Growth Lab')
                && str_contains($result, 'monetization_options'));
    }

    public function test_process_ai_returns_clear_error_for_missing_openrouter_key(): void
    {
        config([
            'services.ai.provider' => 'openrouter',
            'services.openrouter.key' => null,
        ]);
        $this->app->forgetInstance(AiClientInterface::class);

        $token = $this->registerToken('ai-error@example.test');

        $this->withToken($token)
            ->postJson('/api/process-ai', [
                'action' => 'generate_script',
                'payload' => [
                    'idea' => ['title' => 'Test'],
                    'platform' => 'TikTok',
                ],
                'language' => 'en',
            ])
            ->assertStatus(503)
            ->assertJsonPath('error', 'OpenRouter API key is not configured.');
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
