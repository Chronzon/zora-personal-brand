<?php

namespace App\Services\Ai;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class GeminiAiClient implements AiClientInterface
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
            throw new AiProviderException('Gemini API key is not configured.', 503);
        }

        $model = $this->model ?: 'gemini-2.5-flash';
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
            throw new AiProviderException('Gemini request could not connect.', 502);
        }

        if ($response->failed()) {
            $message = data_get($response->json(), 'error.message', 'Gemini request failed.');
            $status = $response->status() === 429 ? 429 : 502;

            throw new AiProviderException("Gemini request failed: {$message}", $status);
        }

        $parts = data_get($response->json(), 'candidates.0.content.parts', []);
        $text = collect(is_array($parts) ? $parts : [])
            ->pluck('text')
            ->filter(fn ($part) => is_string($part) && trim($part) !== '')
            ->implode("\n");

        if (trim($text) === '') {
            throw new AiProviderException('Gemini returned an invalid response.', 502);
        }

        return trim($text);
    }
}
