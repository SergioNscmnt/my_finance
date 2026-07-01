## Why

O repositório mantém modelos, tabelas e serviços de investimento/dados de mercado, mas as rotas atuais não expõem essa superfície e o workspace mostra remoções de controllers/views relacionados. É necessário decidir se o domínio de investimentos será removido, congelado ou reintroduzido para reduzir código órfão e clarear a direção do produto.

## What Changes

- Inventariar artefatos atuais do domínio de investimentos: models, migrations, serviços, assets, rotas removidas e dados persistidos.
- Escolher uma estratégia: remover, congelar/documentar ou reintroduzir a funcionalidade.
- Definir plano de migração ou reativação conforme a estratégia escolhida.
- Evitar misturar esta decisão com refatorações de fluxo de caixa pessoal.

## Capabilities

### New Capabilities

- `investment-domain-resolution`: Define como o domínio de investimentos deve ser decidido e tratado no projeto.

### Modified Capabilities

- Nenhuma.

## Impact

- Código afetado: modelos, serviços, rotas, controllers, views, migrations e seeds relacionados a investimentos, dependendo da decisão.
- Banco de dados: possível remoção, preservação ou migração das tabelas de investimento.
- APIs e UI: podem ser removidas ou reintroduzidas em mudança posterior.
- Dependências: possíveis ajustes em serviços de mercado e variáveis de ambiente.
