<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Ai\AiClientMetadataAware;
use App\Services\Ai\AiClientInterface;
use App\Services\Ai\AiProviderException;
use App\Services\Ai\PromptBuilder;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;
use Throwable;

class AiController extends Controller
{
    public function __construct(
        private readonly PromptBuilder $promptBuilder,
        private readonly AiClientInterface $aiClient,
    ) {}

    public function process(Request $request): JsonResponse
    {
        $data = $request->validate([
            'action' => ['required', 'string'],
            'payload' => ['nullable', 'array'],
            'language' => ['nullable', 'string'],
        ]);

        $payload = $data['payload'] ?? [];
        $language = $data['language'] ?? 'id';

        try {
            $prompt = $this->promptBuilder->build($data['action'], $payload, $language);
            $result = $this->aiClient->generate($prompt, [
                'action' => $data['action'],
                'payload' => $payload,
                'language' => $language,
            ]);

            return response()->json([
                'result' => $result,
                'ai' => $this->aiClient instanceof AiClientMetadataAware
                    ? $this->aiClient->metadata()
                    : null,
            ]);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['error' => $exception->getMessage()], 422);
        } catch (AiProviderException $exception) {
            Log::warning('AI provider request failed.', [
                'category' => $exception->category(),
                'status_code' => $exception->statusCode(),
                'message' => $exception->getMessage(),
                'metadata' => $this->aiClient instanceof AiClientMetadataAware
                    ? $this->aiClient->metadata()
                    : null,
            ]);

            return response()->json([
                'error' => $this->userSafeAiError($exception),
                'error_category' => $exception->category(),
                'ai' => $this->aiClient instanceof AiClientMetadataAware
                    ? $this->aiClient->metadata()
                    : null,
            ], $exception->statusCode());
        } catch (Throwable) {
            return response()->json(['error' => 'AI service failed. Please try again.'], 500);
        }
    }

    private function userSafeAiError(AiProviderException $exception): string
    {
        return match ($exception->category()) {
            'timeout' => 'AI suggestions took too long. Please try again.',
            'rate_limit', 'quota_exceeded' => 'AI suggestions are temporarily unavailable. Please try again later or continue manually.',
            'auth_error' => 'AI service is not configured correctly. Please contact support.',
            'invalid_request' => 'AI could not process this request. Please adjust your input and try again.',
            default => 'AI suggestions are temporarily unavailable. Please try again or continue manually.',
        };
    }
}
