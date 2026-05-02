<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'user_id',
    'pillar',
    'title',
    'angle',
    'content_overview',
    'viral_potential',
    'insight',
    'platform',
])]
class ContentIdea extends Model
{
}
