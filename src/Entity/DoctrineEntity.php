<?php

declare(strict_types=1);

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use Doctrine\ORM\Mapping\Column;
use Doctrine\ORM\Mapping\Entity;
use Doctrine\ORM\Mapping\GeneratedValue;
use Doctrine\ORM\Mapping\Id;

#[Entity]
#[ApiResource]
class DoctrineEntity
{
    #[Id]
    #[Column(type: 'integer')]
    #[GeneratedValue(strategy: 'AUTO')]
    private ?int $id;

    #[Column]
    private string $myValue = '';

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getMyValue(): string
    {
        return $this->myValue;
    }

    public function setMyValue(string $myValue): void
    {
        $this->myValue = $myValue;
    }
}
