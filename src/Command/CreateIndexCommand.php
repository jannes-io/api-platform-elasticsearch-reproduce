<?php

declare(strict_types=1);

namespace App\Command;

use App\Entity\ElasticsearchEntity;
use Elasticsearch\ClientBuilder;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

final class CreateIndexCommand extends Command
{
    public function __construct(private readonly string $host,)
    {
        parent::__construct('app:create-index');
    }

    public function run(InputInterface $input, OutputInterface $output): int
    {
        $client = (new ClientBuilder())
            ->setHosts([$this->host])
            ->build();

        $client->indices()->create([
            'index' => 'elasticsearch_entity',
            'body' => [
                'mappings' => ElasticsearchEntity::getMapping()
            ]
        ]);

        return Command::SUCCESS;
    }
}
