## Context

O projeto usa `mysql2` em desenvolvimento/teste e `pg` em produção quando `DATABASE_URL` está presente. O entrypoint evita `db:prepare` porque o schema gerado em MySQL pode quebrar em PostgreSQL.

## Goals / Non-Goals

**Goals:**

- Definir oficialmente o banco suportado em produção.
- Ajustar documentação e validação para o adapter escolhido.
- Reduzir divergência entre ambiente local, teste e deploy.

**Non-Goals:**

- Migrar dados reais de produção.
- Alterar regras de negócio.
- Reescrever o modelo de dados.

## Decisions

- Tratar a escolha do banco como decisão explícita antes de ajustar código.
  - Justificativa: PostgreSQL e MariaDB têm diferenças de schema, JSON, índices e collation.
  - Alternativa considerada: manter ambos indefinidamente. Rejeitada porque aumenta risco sem validação equivalente.
- Validar migrations no adapter escolhido.
  - Justificativa: `schema.rb` gerado em um adapter não garante compatibilidade no outro.
  - Alternativa considerada: confiar apenas em `schema.rb`. Rejeitada pelo risco já documentado no entrypoint.

## Risks / Trade-offs

- Decisão impacta deploy existente -> Mitigação: documentar trade-offs e manter rollback de configuração.
- Remover adapter cedo demais -> Mitigação: primeiro validar decisão, depois limpar dependências.
- Migrations antigas falharem -> Mitigação: testar em banco limpo antes de alterar produção.

## Migration Plan

Definir adapter alvo, validar criação/migração de banco limpo e atualizar documentação/entrypoint. Não migrar dados reais nesta etapa.

## Open Questions

- O deploy final continuará no Render com PostgreSQL ou mudará para ambiente com MariaDB?
