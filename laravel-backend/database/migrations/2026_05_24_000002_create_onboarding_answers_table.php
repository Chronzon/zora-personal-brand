<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('onboarding_answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('onboarding_step');
            $table->json('selected_answer');
            $table->string('source')->default('manual');
            $table->string('model_provider')->nullable();
            $table->string('model_name')->nullable();
            $table->timestamp('completed_at');
            $table->timestamps();

            $table->unique(['user_id', 'onboarding_step']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('onboarding_answers');
    }
};
