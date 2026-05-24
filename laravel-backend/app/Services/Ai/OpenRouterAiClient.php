<?php

namespace App\Services\Ai;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class OpenRouterAiClient implements AiProviderClientInterface
{
    public function __construct(
        private readonly ?string $apiKey,
        private readonly ?string $model,
    ) {}

    public function providerName(): string
    {
        return 'openrouter';
    }

    public function modelName(): ?string
    {
        return $this->model ?: 'deepseek/deepseek-chat-v3.1:free';
    }

    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string
    {
        if (! $this->apiKey) {
            throw new AiProviderException('OpenRouter API key is not configured.', 503, 'auth_error');
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
                    'model' => $this->modelName(),
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
            throw new AiProviderException('OpenRouter request timed out or could not connect.', 504, 'timeout');
        }

        if ($response->failed()) {
            $message = data_get($response->json(), 'error.message', 'OpenRouter request failed.');
            $status = $this->statusForResponse($response->status());
            $category = $this->categoryForResponse($response->status(), is_string($message) ? $message : '');

            throw new AiProviderException("OpenRouter request failed: {$message}", $status, $category);
        }

        $content = data_get($response->json(), 'choices.0.message.content');

        if (! is_string($content) || trim($content) === '') {
            throw new AiProviderException('OpenRouter returned an invalid response.', 502, 'invalid_response');
        }

        return trim($content);
    }

    private function statusForResponse(int $responseStatus): int
    {
        if ($responseStatus === 429) {
            return 429;
        }

        if (in_array($responseStatus, [400, 401, 403, 422], true)) {
            return $responseStatus;
        }

        return $responseStatus >= 500 ? 502 : 502;
    }

    private function categoryForResponse(int $responseStatus, string $message): string
    {
        $lowerMessage = strtolower($message);

        if ($responseStatus === 429) {
            return str_contains($lowerMessage, 'quota') ? 'quota_exceeded' : 'rate_limit';
        }

        if (in_array($responseStatus, [401, 403], true)) {
            return 'auth_error';
        }

        if (in_array($responseStatus, [400, 422], true)) {
            return 'invalid_request';
        }

        if ($responseStatus >= 500) {
            return 'provider_unavailable';
        }

        return 'unknown';
    }
}
