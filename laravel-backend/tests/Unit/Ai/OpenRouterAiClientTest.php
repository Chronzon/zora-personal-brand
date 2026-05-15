<?php

namespace Tests\Unit\Ai;

use App\Services\Ai\AiProviderException;
use App\Services\Ai\OpenRouterAiClient;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class OpenRouterAiClientTest extends TestCase
{
    public function test_it_parses_chat_completion_content(): void
    {
        Http::fake([
            'openrouter.ai/*' => Http::response([
                'choices' => [
                    [
                        'message' => [
                            'role' => 'assistant',
                            'content' => 'Generated answer',
                        ],
                    ],
                ],
            ]),
        ]);

        $client = new OpenRouterAiClient('test-key', 'deepseek/deepseek-chat-v3.1:free');

        $this->assertSame('Generated answer', $client->generate('Build a prompt'));

        Http::assertSent(fn ($request) => $request->hasHeader('Authorization', 'Bearer test-key')
            && $request['model'] === 'deepseek/deepseek-chat-v3.1:free'
            && $request['messages'][1]['content'] === 'Build a prompt');
    }

    public function test_it_requires_api_key(): void
    {
        $this->expectException(AiProviderException::class);
        $this->expectExceptionMessage('OpenRouter API key is not configured.');

        (new OpenRouterAiClient(null, 'model'))->generate('Prompt');
    }

    public function test_it_rejects_malformed_response(): void
    {
        Http::fake([
            'openrouter.ai/*' => Http::response(['choices' => []]),
        ]);

        $this->expectException(AiProviderException::class);
        $this->expectExceptionMessage('OpenRouter returned an invalid response.');

        (new OpenRouterAiClient('test-key', 'model'))->generate('Prompt');
    }
}

