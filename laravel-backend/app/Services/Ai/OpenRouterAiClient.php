<?php

namespace App\Services\Ai;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class OpenRouterAiClient implements AiClientInterface
{
    public function __construct(
        private readonly ?string $apiKey,
        private readonly ?string $model,
    ) {}

    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string
    {
        if (! $this->apiKey) {
            throw new AiProviderException('OpenRouter API key is not configured.', 503);
        }

        try {
            $response = Http::timeout(120)
                ->withToken($this->apiKey)
                ->acceptJson()
                ->withHeaders([
                    'HTTP-Referer' => (string) config('app.url'),
                    'X-Title' => (string) config('app.name', 'Personal Branding Zora'),
                ])
                ->post('https://openrouter.ai/api/v1/chat/completions', [
                    'model' => $this->model ?: 'deepseek/deepseek-chat-v3.1:free',
                    'messages' => [
                        [
                            'role' => 'system',
                            'content' => 'You are a personal branding expert AI.',
                        ],
                        [
                            'role' => 'user',
                            'content' => $prompt,
                        ],
                    ],
                    'temperature' => 0.7,
                ]);
        } catch (ConnectionException) {
            throw new AiProviderException('OpenRouter request could not connect.', 502);
        }

        if ($response->failed()) {
            $message = data_get($response->json(), 'error.message', 'OpenRouter request failed.');
            $status = $response->status() === 429 ? 429 : 502;

            throw new AiProviderException("OpenRouter request failed: {$message}", $status);
        }

        $content = data_get($response->json(), 'choices.0.message.content');

        if (! is_string($content) || trim($content) === '') {
            throw new AiProviderException('OpenRouter returned an invalid response.', 502);
        }

        return trim($content);
    }
}
