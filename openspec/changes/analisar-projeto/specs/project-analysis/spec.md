## ADDED Requirements

### Requirement: Inventário da arquitetura do repositório
A análise do projeto DEVE documentar a estrutura atual da aplicação, principais componentes Rails, áreas de domínio, rotas, modelo de persistência, configuração e premissas de deploy encontradas no repositório.

#### Scenario: Inventário de arquitetura é produzido
- **WHEN** a análise do projeto for concluída
- **THEN** o relatório inclui a stack Rails observada, rotas principais, controllers, models, tabelas do banco, convenções de frontend e setup de ambiente/deploy

#### Scenario: Evidência é rastreável
- **WHEN** o relatório descreve um componente ou comportamento do sistema
- **THEN** o relatório cita o arquivo relevante do repositório ou a fonte de configuração usada como evidência

### Requirement: Avaliação de riscos e lacunas
A análise do projeto DEVE identificar riscos técnicos, comportamentais, de integridade de dados, testes, segurança e operação que sejam visíveis a partir da inspeção do repositório.

#### Scenario: Riscos incluem severidade e justificativa
- **WHEN** um risco ou lacuna é listado
- **THEN** o relatório inclui sua severidade, evidência, impacto e justificativa

#### Scenario: Sinais de confiança ausentes são registrados
- **WHEN** testes, CI, verificação em runtime ou documentação estão ausentes ou incompletos
- **THEN** o relatório registra a lacuna e explica a área de confiança afetada

### Requirement: Recomendações priorizadas
A análise do projeto DEVE fornecer recomendações priorizadas que possam ser convertidas em trabalhos de implementação focados.

#### Scenario: Recomendações são acionáveis
- **WHEN** uma recomendação é incluída
- **THEN** ela nomeia a área afetada, a próxima ação proposta, o benefício esperado e a prioridade sugerida

#### Scenario: Escopo de follow-up é separado
- **WHEN** uma recomendação exige mudanças de código
- **THEN** o relatório distingue esse trabalho posterior da análise em si

### Requirement: Análise não invasiva
A análise do projeto DEVE evitar mudanças no comportamento em runtime da aplicação, schema do banco, rotas, dependências ou UI voltada ao usuário.

#### Scenario: Análise não altera comportamento
- **WHEN** a mudança é implementada
- **THEN** apenas documentação ou artefatos de análise do OpenSpec são adicionados ou atualizados
