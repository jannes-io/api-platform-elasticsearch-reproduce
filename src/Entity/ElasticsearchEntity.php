<?php

declare(strict_types=1);

namespace App\Entity;

use ApiPlatform\Metadata\ApiProperty;
use ApiPlatform\Metadata\ApiResource;
use JsonSerializable;
use Symfony\Component\Serializer\Annotation\Groups;

#[ApiResource(
    normalizationContext: ['groups' => 'read']
)]
final class ElasticsearchEntity implements JsonSerializable
{
    #[ApiProperty(identifier: true)]
    private string $id;
    private string $myValue = '';

    public function __construct(string $id) {
        $this->id = $id ?? uniqid('', false);
    }

    #[Groups(['read'])]
    public function getId(): string
    {
        return $this->id;
    }

    #[Groups(['read'])]
    public function getMyValue(): string
    {
        return $this->myValue;
    }

    public function setMyValue(string $myValue): void
    {
        $this->myValue = $myValue;
    }

    public static function getMapping(): array
    {
        return [
            'properties' => [
                'id' => ['type' => 'keyword'],
                'my_value' => ['type' => 'text']
            ]
        ];
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'my_value' => $this->getMyValue()
        ];
    }
}
