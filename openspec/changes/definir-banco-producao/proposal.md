## Why

O projeto usa MySQL/MariaDB em desenvolvimento e teste, mas aceita PostgreSQL em produção via `DATABASE_URL`. Essa divergência já aparece no entrypoint, que evita `db:prepare` porque o `schema.rb` gerado em MySQL pode quebrar no PostgreSQL, criando risco de deploy e migrations inconsistentes.

## What Changes

- Definir explicitamente o banco oficial de produção: PostgreSQL no Render ou MariaDB em ambiente compatível.
- Ajustar documentação, configuração e entrypoint de acordo com a decisão.
- Validar migrations e schema no banco escolhido para produção.
- Separar a decisão de infraestrutura de mudanças de regra de negócio.

## Capabilities

### New Capabilities

- `production-database-strategy`: Define a estratégia suportada de banco de dados em produção e seu fluxo de validação.

### Modified Capabilities

- Nenhuma.

## Impact

- Configuração afetada: `config/database.yml`, `Gemfile`, `Dockerfile`, `bin/docker-entrypoint`, README e documentação de deploy.
- Banco de dados: validação de migrations/schema no adapter escolhido.
- APIs e UI: nenhuma mudança.
- Dependências: pode remover ou consolidar adapter de banco depois da decisão.
