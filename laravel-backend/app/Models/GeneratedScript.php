<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'user_id',
    'title',
    'platform',
    'script',
    'original_idea_id',
    'pillar',
])]
class GeneratedScript extends Model
{
}
