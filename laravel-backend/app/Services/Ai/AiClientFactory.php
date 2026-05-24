<?php

namespace App\Services\Ai;

class AiClientFactory
{
    public function make(): AiClientInterface
    {
        $primary = $this->makeProvider(
            strtolower((string) config('services.ai.provider', 'local')),
            config('services.ai.model'),
        );

        $fallbackProvider = config('services.ai.fallback_provider');
        $fallback = is_string($fallbackProvider) && trim($fallbackProvider) !== ''
            ? $this->makeProvider(strtolower($fallbackProvider), config('services.ai.fallback_model'))
            : null;

        return new FallbackAiClient($primary, $fallback);
    }

    private function makeProvider(string $provider, mixed $model): AiProviderClientInterface
    {
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
            default => throw new AiProviderException("Unsupported AI provider: {$provider}", 500, 'invalid_request'),
        };
    }
}
