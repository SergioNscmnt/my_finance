## Context

As regras de transações, categorias de cartão, faturas e importação de PDF afetam diretamente saldos e relatórios. Existem arquivos Minitest, mas os testes de modelos principais ainda estão vazios.

## Goals / Non-Goals

**Goals:**

- Cobrir cálculos financeiros críticos com Minitest.
- Criar cenários representativos de parcelamento, fechamento, vencimento, faturas e importação.
- Usar dados de teste explícitos e fáceis de revisar.

**Non-Goals:**

- Refatorar regras financeiras sem necessidade demonstrada.
- Trocar framework de testes.
- Cobrir UI end-to-end nesta mudança.

## Decisions

- Usar Minitest existente.
  - Justificativa: já é o framework configurado no projeto.
  - Alternativa considerada: adicionar RSpec. Rejeitada por aumentar escopo e dependências.
- Priorizar models/services antes de system tests.
  - Justificativa: as regras críticas estão em models e services.
  - Alternativa considerada: cobrir apenas fluxos de tela. Rejeitada por menor precisão em cálculos.

## Risks / Trade-offs

- Fixtures frágeis -> Mitigação: preferir criação explícita de objetos por teste quando melhorar clareza.
- Testes revelarem bug existente -> Mitigação: registrar falha e corrigir apenas se estiver dentro do escopo acordado.
- Banco local indisponível -> Mitigação: depender da mudança `automatizar-validacao-local`.

## Migration Plan

Não há migração de dados. A mudança adiciona testes e eventuais fixtures.

## Open Questions

- Devemos incluir fixture textual real de extrato Banco do Brasil ou começar com linhas extraídas sintéticas?
