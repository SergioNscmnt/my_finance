## ADDED Requirements

### Requirement: Coleta de sugestões baseada em evidência
O roadmap de melhorias DEVE coletar sugestões a partir de evidências do repositório, achados da análise do projeto ou lacunas explicitamente observadas.

#### Scenario: Sugestão possui origem rastreável
- **WHEN** uma melhoria é listada
- **THEN** ela informa a evidência, arquivo, área do sistema ou achado que motivou a sugestão

#### Scenario: Sugestão sem evidência é marcada
- **WHEN** uma melhoria depende de premissa não verificada
- **THEN** ela é marcada como hipótese ou pergunta aberta antes de ser priorizada para implementação

### Requirement: Priorização de melhorias
O roadmap de melhorias DEVE priorizar cada sugestão usando critérios explícitos de impacto, esforço, risco reduzido, dependências e urgência.

#### Scenario: Melhoria é priorizada
- **WHEN** uma melhoria entra no roadmap
- **THEN** ela recebe prioridade sugerida e justificativa baseada nos critérios definidos

#### Scenario: Dependência é identificada
- **WHEN** uma melhoria depende de outra mudança
- **THEN** o roadmap registra a dependência e posiciona a melhoria na ordem apropriada

### Requirement: Agrupamento por área de atuação
O roadmap de melhorias DEVE agrupar sugestões por tipo de trabalho para facilitar planejamento e execução.

#### Scenario: Sugestões são categorizadas
- **WHEN** o roadmap é produzido
- **THEN** cada sugestão pertence a uma área como testes, arquitetura, dados, segurança, operação, UX, documentação ou regras de negócio

#### Scenario: Melhorias de produto são separadas
- **WHEN** uma sugestão altera comportamento funcional ou regra financeira
- **THEN** ela é marcada como dependente de decisão de produto antes da implementação

### Requirement: Conversão em próximos OpenSpecs
O roadmap de melhorias DEVE destacar quais recomendações estão prontas para virar mudanças OpenSpec independentes.

#### Scenario: Próxima mudança é proposta
- **WHEN** uma recomendação está clara o suficiente para implementação
- **THEN** o roadmap sugere um nome de mudança OpenSpec, objetivo e escopo inicial

#### Scenario: Trabalho não pronto é mantido no backlog
- **WHEN** uma recomendação ainda exige investigação ou decisão
- **THEN** ela permanece no backlog com a pergunta pendente registrada

### Requirement: Não invasividade do roadmap
O roadmap de melhorias DEVE evitar alterações diretas em código, banco, rotas, dependências ou interface.

#### Scenario: Roadmap não altera runtime
- **WHEN** a mudança é implementada
- **THEN** apenas documentação ou artefatos OpenSpec relacionados a melhorias são adicionados ou atualizados
