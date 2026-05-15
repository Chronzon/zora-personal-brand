<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BrandProfile;
use App\Models\UserProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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
            'content_pillars' => ['nullable', 'array'],
            'content_pillars.*' => ['string', 'max:255'],
        ]);

        $profile = BrandProfile::query()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $data + ['user_id' => $request->user()->id]
        );

        return response()->json(['data' => $profile]);
    }
}
