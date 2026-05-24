<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BrandProfile;
use App\Models\OnboardingAnswer;
use App\Models\UserProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function userProfile(Request $request): JsonResponse
    {
        $profile = UserProfile::query()->where('user_id', $request->user()->id)->first();

        return response()->json(['data' => $profile]);
    }

    public function saveUserProfile(Request $request): JsonResponse
    {
        $data = $request->validate([
            'full_name' => ['nullable', 'string', 'max:255'],
            'what_i_love' => ['nullable', 'string'],
            'what_im_good_at' => ['nullable', 'string'],
            'what_the_world_needs' => ['nullable', 'string'],
            'what_i_can_be_paid_for' => ['nullable', 'string'],
        ]);

        $profile = UserProfile::query()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $data + ['user_id' => $request->user()->id]
        );

        return response()->json(['data' => $profile]);
    }

    public function brandProfile(Request $request): JsonResponse
    {
        $profile = BrandProfile::query()->where('user_id', $request->user()->id)->first();

        return response()->json(['data' => $profile]);
    }

    public function saveBrandProfile(Request $request): JsonResponse
    {
        $data = $request->validate([
            'selected_profile_name' => ['nullable', 'string', 'max:255'],
            'selected_category' => ['nullable', 'string', 'max:255'],
            'selected_micro_niche' => ['nullable', 'string', 'max:255'],
            'selected_premise' => ['nullable', 'string'],
            'tone_of_voice' => ['nullable', 'string', 'max:255'],
            'target_audience' => ['nullable', 'string'],
            'strengths' => ['nullable', 'string'],
            'weaknesses' => ['nullable', 'string'],
            'opportunities' => ['nullable', 'string'],
            'threats' => ['nullable', 'string'],
            'monetization_options' => ['nullable', 'array'],
            'monetization_options.*' => ['string', 'max:255'],
            'content_pillars' => ['nullable', 'array'],
            'content_pillars.*' => ['string', 'max:255'],
        ]);

        $profile = BrandProfile::query()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $data + ['user_id' => $request->user()->id]
        );

        return response()->json(['data' => $profile]);
    }

    public function onboardingProgress(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $answers = OnboardingAnswer::query()
            ->where('user_id', $userId)
            ->orderBy('completed_at')
            ->get()
            ->map(fn (OnboardingAnswer $answer) => [
                'onboarding_step' => $answer->onboarding_step,
                'selected_answer' => $answer->selected_answer,
                'source' => $answer->source,
                'model_provider' => $answer->model_provider,
                'model_name' => $answer->model_name,
                'completed_at' => $answer->completed_at?->toJSON(),
            ])
            ->values();

        return response()->json([
            'user_profile' => UserProfile::query()->where('user_id', $userId)->first(),
            'brand_profile' => BrandProfile::query()->where('user_id', $userId)->first(),
            'completed_steps' => $answers,
        ]);
    }

    public function saveOnboardingAnswer(Request $request): JsonResponse
    {
        $data = $request->validate([
            'onboarding_step' => [
                'required',
                'string',
                'in:user_profile,profile_name,category,micro_niche,swot,premise,tone_audience,content_pillars',
            ],
            'selected_answer' => ['required', 'array'],
            'source' => ['required', 'string', 'in:manual,primary_ai,fallback_ai,default'],
            'model_provider' => ['nullable', 'string', 'max:255'],
            'model_name' => ['nullable', 'string', 'max:255'],
        ]);

        $userId = $request->user()->id;

        $answer = DB::transaction(function () use ($data, $userId) {
            $answer = OnboardingAnswer::query()->updateOrCreate(
                [
                    'user_id' => $userId,
                    'onboarding_step' => $data['onboarding_step'],
                ],
                [
                    'selected_answer' => $data['selected_answer'],
                    'source' => $data['source'],
                    'model_provider' => $data['model_provider'] ?? null,
                    'model_name' => $data['model_name'] ?? null,
                    'completed_at' => now(),
                ],
            );

            $this->applyOnboardingAnswer($userId, $data['onboarding_step'], $data['selected_answer']);

            return $answer;
        });

        return response()->json(['data' => $answer]);
    }

    /**
     * @param array<string, mixed> $selectedAnswer
     */
    private function applyOnboardingAnswer(int $userId, string $step, array $selectedAnswer): void
    {
        match ($step) {
            'user_profile' => UserProfile::query()->updateOrCreate(
                ['user_id' => $userId],
                $this->onlyFilled($selectedAnswer, [
                    'full_name',
                    'what_i_love',
                    'what_im_good_at',
                    'what_the_world_needs',
                    'what_i_can_be_paid_for',
                ]) + ['user_id' => $userId],
            ),
            'profile_name', 'category', 'micro_niche', 'swot', 'premise', 'tone_audience', 'content_pillars' => BrandProfile::query()->updateOrCreate(
                ['user_id' => $userId],
                $this->brandProfileDataForStep($step, $selectedAnswer) + ['user_id' => $userId],
            ),
            default => null,
        };
    }

    /**
     * @param array<string, mixed> $selectedAnswer
     * @return array<string, mixed>
     */
    private function brandProfileDataForStep(string $step, array $selectedAnswer): array
    {
        $fields = match ($step) {
            'profile_name' => ['selected_profile_name', 'monetization_options'],
            'category' => ['selected_category', 'monetization_options'],
            'micro_niche' => ['selected_micro_niche', 'monetization_options'],
            'swot' => ['strengths', 'weaknesses', 'opportunities', 'threats'],
            'premise' => ['selected_premise'],
            'tone_audience' => ['tone_of_voice', 'target_audience'],
            'content_pillars' => ['content_pillars'],
            default => [],
        };

        return $this->onlyFilled($selectedAnswer, $fields);
    }

    /**
     * @param array<string, mixed> $data
     * @param array<int, string> $fields
     * @return array<string, mixed>
     */
    private function onlyFilled(array $data, array $fields): array
    {
        return Arr::only($data, $fields);
    }
}
