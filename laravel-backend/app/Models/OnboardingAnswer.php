<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'user_id',
    'onboarding_step',
    'selected_answer',
    'source',
    'model_provider',
    'model_name',
    'completed_at',
])]
class OnboardingAnswer extends Model
{
    protected function casts(): array
    {
        return [
            'selected_answer' => 'array',
            'completed_at' => 'datetime',
        ];
    }
}
