## Why

Os cálculos do dashboard aparecem duplicados em controllers como `DashboardController`, `TransactionsController` e `CategoryBudgetsController`. Essa duplicação aumenta o risco de métricas divergentes após create/update/destroy via Turbo e dificulta testar saldos, gráficos, orçamento e faturas.

## What Changes

- Extrair os cálculos de dashboard para um serviço ou query object com contrato claro.
- Reutilizar o mesmo componente em dashboard, respostas Turbo de transações e atualizações de orçamento.
- Manter comportamento visual e valores esperados sem mudança funcional intencional.
- Preparar a lógica para testes focados em métricas financeiras.

## Capabilities

### New Capabilities

- `dashboard-metrics-service`: Define um ponto único para calcular métricas, gráficos, orçamento, faturas e agrupamento mensal do dashboard.

### Modified Capabilities

- Nenhuma.

## Impact

- Código afetado: `DashboardController`, `TransactionsController`, `CategoryBudgetsController` e novo serviço/query object.
- Testes afetados: testes de serviço e possíveis ajustes em controllers.
- Banco de dados: nenhuma mudança de schema.
- APIs e UI: nenhuma mudança intencional de comportamento.
- Dependências: nenhuma prevista.
