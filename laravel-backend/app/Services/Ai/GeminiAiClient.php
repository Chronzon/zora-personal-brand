<?php

namespace App\Services\Ai;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class GeminiAiClient implements AiProviderClientInterface
{
    public function __construct(
        private readonly ?string $apiKey,
        private readonly ?string $model,
    ) {}

    public function providerName(): string
    {
        return 'gemini';
    }

    public function modelName(): ?string
    {
        return $this->model ?: 'gemini-2.5-flash';
    }

    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string
    {
        if (! $this->apiKey) {
            throw new AiProviderException('Gemini API key is not configured.', 503, 'auth_error');
        }

        $model = $this->modelName();
        $url = 'https://generativelanguage.googleapis.com/v1beta/models/'.rawurlencode($model).':generateContent';

        try {
            $response = Http::timeout(120)
                ->acceptJson()
                ->post($url.'?'.http_build_query(['key' => $this->apiKey]), [
                    'systemInstruction' => [
                        'parts' => [
                            ['text' => 'You are a personal branding expert AI.'],
                        ],
                    ],
                    'contents' => [
                        [
                            'role' => 'user',
                            'parts' => [
                                ['text' => $prompt],
                            ],
                        ],
                    ],
                    'generationConfig' => [
                        'temperature' => 0.7,
                    ],
                ]);
        } catch (ConnectionException) {
            throw new AiProviderException('Gemini request timed out or could not connect.', 504, 'timeout');
        }

        if ($response->failed()) {
            $message = data_get($response->json(), 'error.message', 'Gemini request failed.');
            $status = $this->statusForResponse($response->status());
            $category = $this->categoryForResponse($response->status(), is_string($message) ? $message : '');

            throw new AiProviderException("Gemini request failed: {$message}", $status, $category);
        }

        $parts = data_get($response->json(), 'candidates.0.content.parts', []);
        $text = collect(is_array($parts) ? $parts : [])
            ->pluck('text')
            ->filter(fn ($part) => is_string($part) && trim($part) !== '')
            ->implode("\n");

        if (trim($text) === '') {
            throw new AiProviderException('Gemini returned an invalid response.', 502, 'invalid_response');
        }

        return trim($text);
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
