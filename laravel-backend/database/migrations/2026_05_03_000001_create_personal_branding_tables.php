<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('full_name')->nullable();
            $table->text('what_i_love')->nullable();
            $table->text('what_im_good_at')->nullable();
            $table->text('what_the_world_needs')->nullable();
            $table->text('what_i_can_be_paid_for')->nullable();
            $table->timestamps();
        });

        Schema::create('brand_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('selected_profile_name')->nullable();
            $table->string('selected_category')->nullable();
            $table->string('selected_micro_niche')->nullable();
            $table->text('selected_premise')->nullable();
            $table->string('tone_of_voice')->nullable();
            $table->text('target_audience')->nullable();
            $table->text('strengths')->nullable();
            $table->text('weaknesses')->nullable();
            $table->text('opportunities')->nullable();
            $table->text('threats')->nullable();
            $table->json('content_pillars')->nullable();
            $table->timestamps();
        });

        Schema::create('content_ideas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('pillar')->nullable();
            $table->string('title')->nullable();
            $table->text('angle')->nullable();
            $table->text('content_overview')->nullable();
            $table->string('viral_potential')->nullable();
            $table->text('insight')->nullable();
            $table->string('platform')->default('Multi-Platform');
            $table->timestamps();
        });

        Schema::create('generated_scripts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('platform')->default('Multi-Platform');
            $table->longText('script');
            $table->string('original_idea_id')->nullable();
            $table->string('pillar')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('generated_scripts');
        Schema::dropIfExists('content_ideas');
        Schema::dropIfExists('brand_profiles');
        Schema::dropIfExists('user_profiles');
    }
};
