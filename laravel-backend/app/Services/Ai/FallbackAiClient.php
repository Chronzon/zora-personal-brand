<?php

namespace App\Services\Ai;

use Illuminate\Support\Facades\Log;

class FallbackAiClient implements AiClientInterface, AiClientMetadataAware
{
    /**
     * @var array<string, mixed>
     */
    private array $metadata = [];

    public function __construct(
        private readonly AiProviderClientInterface $primary,
        private readonly ?AiProviderClientInterface $fallback,
    ) {}

    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string
    {
        $this->metadata = [];

        try {
            $result = $this->primary->generate($prompt, $context);
            $this->metadata = $this->successMetadata($this->primary, 'primary_ai', false);

            return $result;
        } catch (AiProviderException $primaryException) {
            $this->metadata = $this->failureMetadata($this->primary, $primaryException, false);

            if (! $this->shouldFallback($primaryException) || $this->fallback === null) {
                throw $primaryException;
            }

            Log::warning('Primary AI provider failed; trying fallback provider.', [
                'provider' => $this->primary->providerName(),
                'model' => $this->primary->modelName(),
                'category' => $primaryException->category(),
                'status_code' => $primaryException->statusCode(),
            ]);

            try {
                $result = $this->fallback->generate($prompt, $context);
                $this->metadata = $this->successMetadata(
                    $this->fallback,
                    'fallback_ai',
                    true,
                    $primaryException->category(),
                );

                return $result;
            } catch (AiProviderException $fallbackException) {
                $this->metadata = $this->failureMetadata($this->fallback, $fallbackException, true, $primaryException->category());

                throw $fallbackException;
            }
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function metadata(): array
    {
        return $this->metadata;
    }

    private function shouldFallback(AiProviderException $exception): bool
    {
        return in_array($exception->category(), [
            'rate_limit',
            'quota_exceeded',
            'provider_unavailable',
            'invalid_response',
        ], true);
    }

    /**
     * @return array<string, mixed>
     */
    private function successMetadata(
        AiProviderClientInterface $client,
        string $source,
        bool $usedFallback,
        ?string $errorCategory = null,
    ): array {
        return [
            'source' => $source,
            'provider' => $client->providerName(),
            'model' => $client->modelName(),
            'used_fallback' => $usedFallback,
            'error_category' => $errorCategory,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function failureMetadata(
        AiProviderClientInterface $client,
        AiProviderException $exception,
        bool $usedFallback,
        ?string $primaryErrorCategory = null,
    ): array {
        return [
            'source' => $usedFallback ? 'fallback_ai' : 'primary_ai',
            'provider' => $client->providerName(),
            'model' => $client->modelName(),
            'used_fallback' => $usedFallback,
            'error_category' => $exception->category(),
            'primary_error_category' => $primaryErrorCategory,
        ];
    }
}
