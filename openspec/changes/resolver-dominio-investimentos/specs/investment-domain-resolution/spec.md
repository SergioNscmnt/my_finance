## ADDED Requirements

### Requirement: Inventário do domínio de investimentos
O projeto DEVE inventariar artefatos de investimento antes de remover ou reintroduzir funcionalidades.

#### Scenario: Artefatos são listados
- **WHEN** a decisão do domínio é preparada
- **THEN** models, serviços, migrations, rotas, views e dados relacionados são identificados

### Requirement: Estratégia de domínio definida
O projeto DEVE escolher e documentar uma estratégia para investimentos.

#### Scenario: Estratégia é escolhida
- **WHEN** a mudança é concluída
- **THEN** o domínio está classificado como remover, congelar ou reintroduzir com justificativa

### Requirement: Plano de execução seguro
O projeto DEVE separar ações destrutivas de schema de decisões documentais.

#### Scenario: Remoção exige plano
- **WHEN** a estratégia escolhida envolve remoção
- **THEN** existe plano para código, tabelas, dados e rollback
