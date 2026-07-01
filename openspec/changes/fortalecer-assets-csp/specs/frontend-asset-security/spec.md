## ADDED Requirements

### Requirement: Origem de assets frontend definida
O projeto DEVE definir se dependências frontend críticas são locais ou carregadas por CDN.

#### Scenario: Origem documentada
- **WHEN** a configuração frontend é revisada
- **THEN** Chart.js, Tom Select e Flatpickr têm origem e versão documentadas

### Requirement: CSP configurada
O projeto DEVE configurar Content Security Policy compatível com os assets usados.

#### Scenario: CSP permite assets necessários
- **WHEN** a aplicação renderiza o layout
- **THEN** scripts e estilos necessários são permitidos sem abrir permissões genéricas desnecessárias

### Requirement: Componentes frontend validados
O projeto DEVE validar componentes que dependem dos assets afetados.

#### Scenario: Componentes continuam funcionais
- **WHEN** charts, selects e datepicker são usados
- **THEN** eles carregam e funcionam após a alteração de assets/CSP
