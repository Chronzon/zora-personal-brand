<?php

namespace App\Services\Ai;

use RuntimeException;

class AiProviderException extends RuntimeException
{
    public function __construct(
        string $message,
        private readonly int $statusCode = 502,
        private readonly string $category = 'unknown',
    )
    {
        parent::__construct($message);
    }

    public function statusCode(): int
    {
        return $this->statusCode;
    }

    public function category(): string
    {
        return $this->category;
    }
}
