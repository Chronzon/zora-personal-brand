<?php

use App\Http\Controllers\Api\AiController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Middleware\ApiTokenAuth;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => ['status' => 'ok']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware(ApiTokenAuth::class)->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/user-profile', [ProfileController::class, 'userProfile']);
    Route::put('/user-profile', [ProfileController::class, 'saveUserProfile']);

    Route::get('/brand-profile', [ProfileController::class, 'brandProfile']);
    Route::put('/brand-profile', [ProfileController::class, 'saveBrandProfile']);

    Route::get('/onboarding-progress', [ProfileController::class, 'onboardingProgress']);
    Route::post('/onboarding-answers', [ProfileController::class, 'saveOnboardingAnswer']);

    Route::post('/process-ai', [AiController::class, 'process']);

    Route::post('/content-ideas', [ContentController::class, 'storeIdeas']);
    Route::get('/generated-scripts', [ContentController::class, 'scripts']);
    Route::post('/generated-scripts', [ContentController::class, 'storeScript']);
    Route::delete('/generated-scripts/{script}', [ContentController::class, 'deleteScript']);
});
