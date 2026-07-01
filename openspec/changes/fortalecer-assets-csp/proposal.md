## Why

O layout carrega Chart.js, Tom Select e Flatpickr por CDN, enquanto a política de Content Security Policy está comentada. Isso cria dependência operacional externa para recursos críticos da UI e deixa a postura de segurança de scripts/estilos pouco explícita.

## What Changes

- Decidir entre vendorizar/pinar assets externos no pipeline local ou manter CDN com CSP explícita.
- Configurar uma política CSP compatível com os assets necessários.
- Validar charts, selects, datepicker, tema e modais após a mudança.
- Reduzir dependência externa ou torná-la intencional e documentada.

## Capabilities

### New Capabilities

- `frontend-asset-security`: Define como dependências frontend externas e CSP devem ser gerenciadas com segurança.

### Modified Capabilities

- Nenhuma.

## Impact

- Código afetado: layout, importmap/assets, initializers de segurança e possivelmente arquivos vendorizados.
- UI afetada: charts, selects, datepicker e componentes Stimulus relacionados.
- Segurança: CSP passa a ser configurada ou documentada explicitamente.
- Banco de dados e APIs: nenhuma mudança.
- Dependências: pode alterar origem de assets frontend, sem mudar regras de negócio.
