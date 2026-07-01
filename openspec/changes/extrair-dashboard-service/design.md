## Context

Os cálculos de dashboard estão espalhados por `DashboardController`, `TransactionsController` e `CategoryBudgetsController`. A duplicação afeta saldo, gráficos, orçamento, faturas e agrupamento de transações.

## Goals / Non-Goals

**Goals:**

- Criar um serviço/query object único para dados do dashboard.
- Reutilizar o resultado em página completa e respostas Turbo.
- Preservar comportamento atual.

**Non-Goals:**

- Redesenhar a UI.
- Alterar regras financeiras.
- Adicionar novas métricas.

## Decisions

- Criar serviço de aplicação com entrada `user`, `params` e data de referência.
  - Justificativa: controllers precisam do mesmo payload com pequenas variações.
  - Alternativa considerada: mover métodos para concern. Rejeitada por manter lógica pesada em camada de controller.
- Manter payload compatível com views atuais.
  - Justificativa: reduz risco visual e facilita refatoração incremental.
  - Alternativa considerada: reescrever views. Rejeitada por ampliar escopo.

## Risks / Trade-offs

- Refatoração alterar valores -> Mitigação: criar testes de comparação antes/depois para cenários principais.
- Serviço ficar grande demais -> Mitigação: extrair subcomponentes apenas quando houver necessidade real.
- Dependência de params -> Mitigação: normalizar filtros no serviço e testar entradas permitidas.

## Migration Plan

Adicionar serviço, adaptar controllers um por vez e validar que views/Turbo recebem os mesmos dados esperados.

## Open Questions

- O serviço deve retornar objeto estruturado ou hash compatível com os nomes atuais?
