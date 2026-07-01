## ADDED Requirements

### Requirement: Fluxo reprodutível de validação local
O projeto DEVE fornecer um fluxo documentado para preparar banco de teste e executar a suíte local.

#### Scenario: Validação local documentada
- **WHEN** um desenvolvedor consulta as instruções de validação
- **THEN** encontra comandos para subir banco, preparar schema e executar `bin/rails test`

#### Scenario: Banco indisponível é tratado
- **WHEN** o banco de teste não está ativo
- **THEN** as instruções indicam como iniciar o serviço necessário antes dos testes

### Requirement: Compatibilidade com ambiente existente
O fluxo de validação DEVE usar a configuração Docker/Rails já existente no projeto.

#### Scenario: Uso de Docker Compose
- **WHEN** o fluxo principal é executado
- **THEN** ele usa o serviço MariaDB definido em `docker-compose.yml` ou documenta claramente alternativa equivalente
