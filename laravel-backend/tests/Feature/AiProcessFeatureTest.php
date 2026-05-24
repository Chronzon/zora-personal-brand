<?php

namespace Tests\Feature;

use App\Services\Ai\AiClientInterface;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
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
            ->assertJsonPath('error', 'AI service is not configured correctly. Please contact support.')
            ->assertJsonPath('error_category', 'auth_error');
    }

    public function test_process_ai_falls_back_when_gemini_is_rate_limited(): void
    {
        config([
            'services.ai.provider' => 'gemini',
            'services.ai.model' => 'gemini-2.5-flash',
            'services.ai.fallback_provider' => 'openrouter',
            'services.ai.fallback_model' => 'openai/gpt-oss-test',
            'services.gemini.key' => 'gemini-key',
            'services.openrouter.key' => 'openrouter-key',
        ]);
        $this->app->forgetInstance(AiClientInterface::class);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'error' => ['message' => 'Quota exceeded.'],
            ], 429),
            'openrouter.ai/*' => Http::response([
                'choices' => [
                    ['message' => ['content' => 'Fallback answer']],
                ],
            ]),
        ]);

        $token = $this->registerToken('ai-fallback@example.test');

        $this->withToken($token)
            ->postJson('/api/process-ai', [
                'action' => 'generate_script',
                'payload' => [
                    'idea' => ['title' => 'Test'],
                    'platform' => 'TikTok',
                ],
                'language' => 'en',
            ])
            ->assertOk()
            ->assertJsonPath('result', 'Fallback answer')
            ->assertJsonPath('ai.source', 'fallback_ai')
            ->assertJsonPath('ai.provider', 'openrouter')
            ->assertJsonPath('ai.model', 'openai/gpt-oss-test')
            ->assertJsonPath('ai.used_fallback', true)
            ->assertJsonPath('ai.error_category', 'quota_exceeded');
    }

    public function test_process_ai_does_not_fall_back_when_gemini_times_out(): void
    {
        config([
            'services.ai.provider' => 'gemini',
            'services.ai.model' => 'gemini-2.5-flash',
            'services.ai.fallback_provider' => 'openrouter',
            'services.ai.fallback_model' => 'openai/gpt-oss-test',
            'services.gemini.key' => 'gemini-key',
            'services.openrouter.key' => 'openrouter-key',
        ]);
        $this->app->forgetInstance(AiClientInterface::class);

        Http::fake([
            'generativelanguage.googleapis.com/*' => fn () => throw new ConnectionException('timeout'),
            'openrouter.ai/*' => Http::response([
                'choices' => [
                    ['message' => ['content' => 'Should not be used']],
                ],
            ]),
        ]);

        $token = $this->registerToken('ai-timeout@example.test');

        $this->withToken($token)
            ->postJson('/api/process-ai', [
                'action' => 'generate_script',
                'payload' => [
                    'idea' => ['title' => 'Test'],
                    'platform' => 'TikTok',
                ],
                'language' => 'en',
            ])
            ->assertStatus(504)
            ->assertJsonPath('error', 'AI suggestions took too long. Please try again.')
            ->assertJsonPath('error_category', 'timeout')
            ->assertJsonPath('ai.used_fallback', false);

        Http::assertNotSent(fn ($request) => str_contains($request->url(), 'openrouter.ai'));
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
