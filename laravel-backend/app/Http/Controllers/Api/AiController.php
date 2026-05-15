<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Ai\AiClientInterface;
use App\Services\Ai\AiProviderException;
use App\Services\Ai\PromptBuilder;
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

            return response()->json(['result' => $result]);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['error' => $exception->getMessage()], 422);
        } catch (AiProviderException $exception) {
            return response()->json(['error' => $exception->getMessage()], $exception->statusCode());
        } catch (Throwable) {
            return response()->json(['error' => 'AI service failed. Please try again.'], 500);
        }
    }
}
