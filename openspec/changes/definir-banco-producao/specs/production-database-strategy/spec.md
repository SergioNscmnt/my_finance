## ADDED Requirements

### Requirement: Banco de produção definido
O projeto DEVE documentar qual adapter de banco é oficialmente suportado em produção.

#### Scenario: Estratégia está documentada
- **WHEN** um desenvolvedor consulta a documentação de deploy
- **THEN** encontra o banco de produção suportado e as variáveis necessárias

### Requirement: Validação do adapter escolhido
O projeto DEVE validar migrations e preparação de banco no adapter definido para produção.

#### Scenario: Banco limpo é preparado
- **WHEN** a validação de produção é executada em banco limpo
- **THEN** migrations e preparação concluem sem depender de schema incompatível

### Requirement: Configuração consistente
O projeto DEVE alinhar Gemfile, database config e entrypoint com a estratégia escolhida.

#### Scenario: Configuração não conflita
- **WHEN** a aplicação inicia em produção
- **THEN** usa o adapter documentado sem caminhos contraditórios de preparação
