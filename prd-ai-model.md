# PRD: Switchable AI Model Provider

## Purpose

Implement a real AI integration for Personal Branding Zora while keeping the AI provider configurable from `.env`.

The app should be able to switch between OpenRouter and Google AI Studio/Gemini without changing Flutter code or rewriting the Laravel controller.

## Current State

Flutter already calls the Laravel endpoint:

```text
POST /api/process-ai
```

The request body contains:

```json
{
  "action": "generate_identity",
  "payload": {},
  "language": "id"
}
```

Laravel currently handles this endpoint in:

```text
laravel-backend/app/Http/Controllers/Api/AiController.php
```

But `AiController` currently returns local stub/mock responses through `localResult(...)`.

The real intended prompt logic currently exists in:

```text
supabase/functions/process-ai/index.ts
```

That Supabase function should be used as the source of truth for prompt behavior.

## Goal

Replace the Laravel AI stub with a provider-based AI service.

Expected flow:

```text
Flutter
  -> Laravel /api/process-ai
  -> PromptBuilder builds the correct personal-branding prompt
  -> Selected AI provider generates text
  -> Laravel returns { "result": "..." }
  -> Flutter parses and displays the result
```

## Non-Goals

- Do not change Flutter API request shape.
- Do not change Flutter parsing logic unless absolutely necessary.
- Do not hard-code OpenRouter directly inside `AiController`.
- Do not remove the existing Supabase function yet.
- Do not store AI API keys in Flutter.

## Configuration

Add provider configuration to Laravel `.env`:

```env
AI_PROVIDER=openrouter
AI_MODEL=deepseek/deepseek-chat-v3.1:free

OPENROUTER_API_KEY=your_openrouter_key

GEMINI_API_KEY=your_gemini_key
```

To switch providers:

```env
AI_PROVIDER=openrouter
```

or:

```env
AI_PROVIDER=gemini
AI_MODEL=gemini-2.5-flash
```

Add config to:

```text
laravel-backend/config/services.php
```

Recommended config shape:

```php
'ai' => [
    'provider' => env('AI_PROVIDER', 'local'),
    'model' => env('AI_MODEL'),
],

'openrouter' => [
    'key' => env('OPENROUTER_API_KEY'),
],

'gemini' => [
    'key' => env('GEMINI_API_KEY'),
],
```

## Backend Architecture

Create a small AI layer in Laravel.

Recommended files:

```text
laravel-backend/app/Services/Ai/AiClientInterface.php
laravel-backend/app/Services/Ai/OpenRouterAiClient.php
laravel-backend/app/Services/Ai/GeminiAiClient.php
laravel-backend/app/Services/Ai/LocalAiClient.php
laravel-backend/app/Services/Ai/PromptBuilder.php
laravel-backend/app/Services/Ai/AiClientFactory.php
```

### AiClientInterface

All providers must expose the same method:

```php
interface AiClientInterface
{
    public function generate(string $prompt): string;
}
```

### PromptBuilder

`PromptBuilder` is responsible for personal-branding behavior.

It should contain the prompt logic currently found in:

```text
supabase/functions/process-ai/index.ts
```

It should support these actions:

```text
generate_identity
generate_premise
generate_pillars
generate_ideas
generate_script
```

Method shape:

```php
public function build(string $action, array $payload, string $language): string
```

The prompt builder should also include the system instruction:

```text
You are a personal branding expert AI.
Generate all content in the requested language.
```

Language mapping:

```text
en -> English
id -> Bahasa Indonesia
default -> Bahasa Indonesia
```

### OpenRouterAiClient

Use OpenRouter chat completions:

```text
POST https://openrouter.ai/api/v1/chat/completions
```

Request shape:

```json
{
  "model": "deepseek/deepseek-chat-v3.1:free",
  "messages": [
    {
      "role": "system",
      "content": "You are a personal branding expert AI."
    },
    {
      "role": "user",
      "content": "..."
    }
  ]
}
```

Read response from:

```text
choices.0.message.content
```

### GeminiAiClient

Use Google AI Studio/Gemini API with the configured `GEMINI_API_KEY`.

It must return only the final generated text as a string, so the Laravel controller can keep the same response format.

### LocalAiClient

Keep a local provider for offline development and tests.

It can reuse the current stub behavior from `AiController::localResult(...)`.

Use it when:

```env
AI_PROVIDER=local
```

## AiController Requirement

`AiController` should become orchestration-only.

Expected behavior:

```php
public function process(Request $request): JsonResponse
{
    $data = $request->validate([
        'action' => ['required', 'string'],
        'payload' => ['nullable', 'array'],
        'language' => ['nullable', 'string'],
    ]);

    $prompt = $this->promptBuilder->build(
        $data['action'],
        $data['payload'] ?? [],
        $data['language'] ?? 'id'
    );

    $result = $this->aiClient->generate($prompt);

    return response()->json([
        'result' => $result,
    ]);
}
```

## Response Contract

Laravel must always return:

```json
{
  "result": "..."
}
```

Flutter already expects `data['result']`.

Do not change this unless Flutter parsing is updated too.

## Output Format Requirements

The AI output format must stay compatible with existing Flutter parsers.

### generate_identity

Must return a JSON object string:

```json
{
  "categories": ["..."],
  "niches": ["..."],
  "profile_names": ["..."]
}
```

No markdown fences. No explanation outside JSON.

Parsed by:

```text
lib/features/onboarding/data/repositories/onboarding_repository.dart
```

### generate_premise

Must return a numbered list where each item contains a quoted premise.

Example:

```text
1. Title
"Premise text."

2. Title
"Premise text."
```

### generate_pillars

Must return a numbered list with the first line of each item as the pillar title.

Example:

```text
1. Educational
...

2. Entertain
...
```

### generate_ideas

Must return a JSON array string:

```json
[
  {
    "title": "...",
    "angle": "...",
    "content_overview": "...",
    "viral_potential": "...",
    "insight": "...",
    "platform": "TikTok"
  }
]
```

No markdown fences. No explanation outside JSON.

Parsed by:

```text
lib/features/content_creation/data/repositories/content_creation_repository.dart
```

### generate_script

Can return plain text.

It should include:

```text
Hook
Main content
Call to action
Visual suggestions
Hashtags
Music suggestion, when relevant
```

## Error Handling

If the provider API fails, Laravel should return a useful error response:

```json
{
  "message": "AI provider request failed."
}
```

Recommended status codes:

```text
400 -> unsupported action or invalid request
500 -> missing API key or provider failure
502 -> upstream AI provider error
```

Do not expose secret API keys or raw provider stack traces.

## Testing Checklist

Test with:

```env
AI_PROVIDER=local
```

Then test with:

```env
AI_PROVIDER=openrouter
```

Required manual checks:

- `/api/process-ai` returns `{ "result": "..." }`.
- `generate_identity` returns valid JSON object text.
- `generate_ideas` returns valid JSON array text.
- Flutter onboarding can display profile names, categories, and micro-niches.
- Flutter content creation can display generated ideas.
- Flutter script generation can display and save generated scripts.
- Changing `.env` provider does not require Flutter code changes.

## Acceptance Criteria

- Laravel no longer depends on `AiController::localResult(...)` for real AI behavior.
- AI provider can be switched using `.env`.
- OpenRouter can be used for free/low-cost testing.
- Gemini can be enabled later with `.env` only.
- Existing Flutter app continues calling `/api/process-ai`.
- Existing Flutter parsers continue working.
- AI API keys stay only in backend environment variables.

