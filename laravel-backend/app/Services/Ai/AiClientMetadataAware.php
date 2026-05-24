<?php

namespace App\Services\Ai;

interface AiClientMetadataAware
{
    /**
     * @return array<string, mixed>
     */
    public function metadata(): array;
}
