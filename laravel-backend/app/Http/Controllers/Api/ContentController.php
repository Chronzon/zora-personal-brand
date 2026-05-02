<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ContentIdea;
use App\Models\GeneratedScript;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ContentController extends Controller
{
    public function storeIdeas(Request $request): JsonResponse
    {
        $data = $request->validate([
            'pillar' => ['nullable', 'string'],
            'ideas' => ['required', 'array'],
            'ideas.*.title' => ['nullable', 'string'],
            'ideas.*.angle' => ['nullable', 'string'],
            'ideas.*.content_overview' => ['nullable', 'string'],
            'ideas.*.viral_potential' => ['nullable', 'string'],
            'ideas.*.insight' => ['nullable', 'string'],
            'ideas.*.platform' => ['nullable', 'string'],
        ]);

        $ideas = collect($data['ideas'])->map(fn (array $idea) => ContentIdea::query()->create([
            'user_id' => $request->user()->id,
            'pillar' => $data['pillar'] ?? null,
            'title' => $idea['title'] ?? null,
            'angle' => $idea['angle'] ?? null,
            'content_overview' => $idea['content_overview'] ?? null,
            'viral_potential' => $idea['viral_potential'] ?? null,
            'insight' => $idea['insight'] ?? null,
            'platform' => $idea['platform'] ?? 'Multi-Platform',
        ]))->values();

        return response()->json(['data' => $ideas], 201);
    }

    public function scripts(Request $request): JsonResponse
    {
        $scripts = GeneratedScript::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json(['data' => $scripts]);
    }

    public function storeScript(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string'],
            'platform' => ['nullable', 'string'],
            'script' => ['required', 'string'],
            'original_idea_id' => ['nullable', 'string'],
            'pillar' => ['nullable', 'string'],
        ]);

        $script = GeneratedScript::query()->create($data + [
            'user_id' => $request->user()->id,
            'platform' => $data['platform'] ?? 'Multi-Platform',
        ]);

        return response()->json(['data' => $script], 201);
    }

    public function deleteScript(Request $request, GeneratedScript $script): JsonResponse
    {
        abort_if($script->user_id !== $request->user()->id, 404);

        $script->delete();

        return response()->json(['message' => 'Deleted.']);
    }
}
