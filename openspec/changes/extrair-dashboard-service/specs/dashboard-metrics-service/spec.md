## ADDED Requirements

### Requirement: Serviço único de métricas do dashboard
O projeto DEVE centralizar cálculos de dashboard em um serviço reutilizável.

#### Scenario: Dashboard usa serviço
- **WHEN** a página de dashboard é renderizada
- **THEN** métricas, gráficos, orçamento e faturas são carregados a partir do serviço central

### Requirement: Respostas Turbo reutilizam cálculo
O projeto DEVE usar o mesmo cálculo para atualizações Turbo de transações e orçamento.

#### Scenario: Transação atualiza dashboard
- **WHEN** uma transação é criada, alterada ou removida via Turbo
- **THEN** os dados atualizados vêm do mesmo serviço usado pelo dashboard

### Requirement: Comportamento preservado
O serviço DEVE preservar os valores atualmente esperados para cenários equivalentes.

#### Scenario: Métricas permanecem equivalentes
- **WHEN** o mesmo conjunto de transações é processado antes e depois da refatoração
- **THEN** saldo, receitas, despesas e séries mensais permanecem equivalentes
