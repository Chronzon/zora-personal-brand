<?php

namespace App\Services\Ai;

interface AiProviderClientInterface extends AiClientInterface
{
    public function providerName(): string;

    public function modelName(): ?string;
}
