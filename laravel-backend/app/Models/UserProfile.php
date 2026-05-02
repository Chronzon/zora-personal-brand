<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'user_id',
    'full_name',
    'what_i_love',
    'what_im_good_at',
    'what_the_world_needs',
    'what_i_can_be_paid_for',
])]
class UserProfile extends Model
{
}
