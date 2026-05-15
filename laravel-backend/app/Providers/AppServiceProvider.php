<?php

namespace App\Providers;

use App\Services\Ai\AiClientFactory;
use App\Services\Ai\AiClientInterface;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(AiClientInterface::class, function () {
            return (new AiClientFactory)->make();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
