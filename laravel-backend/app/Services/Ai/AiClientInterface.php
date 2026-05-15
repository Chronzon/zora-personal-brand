<?php

namespace App\Services\Ai;

interface AiClientInterface
{
    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string;
}

