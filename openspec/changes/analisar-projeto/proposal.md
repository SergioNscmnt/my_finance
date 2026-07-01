## Why

O projeto cresceu além de um CRUD básico de finanças pessoais e agora inclui orçamentos, faturas de cartão de crédito, dados de carteira de investimentos, dados de mercado e pontos de deploy. Uma análise estruturada é necessária agora para tornar explícitos a arquitetura atual, lacunas, riscos e próximas prioridades técnicas antes de continuar com implementações maiores.

## What Changes

- Adicionar uma capacidade de análise de projeto que produza uma avaliação técnica concisa da aplicação Rails.
- Cobrir fronteiras de domínio atuais, modelo de dados, rotas/controllers, views, integrações de serviços/background quando existirem, configuração de ambiente/deploy e situação de testes.
- Identificar riscos e oportunidades de melhoria com severidade, justificativa e próximas ações concretas.
- Produzir achados apenas como documentação; nenhuma mudança de comportamento em runtime, schema, API ou UI será introduzida.

## Capabilities

### New Capabilities

- `project-analysis`: Define como o repositório deve ser analisado e como o relatório resultante de arquitetura, riscos e recomendações deve ser estruturado.

### Modified Capabilities

- Nenhuma.

## Impact

- Documentação afetada: novo resultado de análise na documentação do repositório ou nos artefatos de implementação do OpenSpec.
- Código afetado: inspeção somente leitura de models, controllers, rotas, views, schema do banco, configuração, setup Docker e arquivos de dependências.
- APIs e comportamento em runtime: nenhum.
- Dependências: nenhuma.
