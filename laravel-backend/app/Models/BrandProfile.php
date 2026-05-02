<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'user_id',
    'selected_profile_name',
    'selected_category',
    'selected_micro_niche',
    'selected_premise',
    'tone_of_voice',
    'target_audience',
    'strengths',
    'weaknesses',
    'opportunities',
    'threats',
    'content_pillars',
])]
class BrandProfile extends Model
{
    protected function casts(): array
    {
        return [
            'content_pillars' => 'array',
        ];
    }
}
