<?php

namespace App\Services\Ai;

class AiClientFactory
{
    public function make(): AiClientInterface
    {
        $provider = strtolower((string) config('services.ai.provider', 'local'));
        $model = config('services.ai.model');

        return match ($provider) {
            'local' => new LocalAiClient,
            'openrouter' => new OpenRouterAiClient(
                config('services.openrouter.key'),
                is_string($model) ? $model : null,
            ),
            'gemini' => new GeminiAiClient(
                config('services.gemini.key'),
                is_string($model) ? $model : null,
            ),
            default => throw new AiProviderException("Unsupported AI provider: {$provider}", 500),
        };
    }
}

