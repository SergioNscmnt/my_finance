## Why

Depois da análise estrutural do projeto, as oportunidades encontradas precisam virar uma lista priorizada e acionável de melhorias. Sem um processo claro de sugestão e priorização, riscos técnicos, lacunas de testes e decisões de produto podem ficar dispersos e difíceis de converter em trabalho real.

## What Changes

- Adicionar uma capacidade de sugestão de melhorias para transformar achados técnicos em recomendações priorizadas.
- Classificar melhorias por área, impacto, esforço, risco reduzido e dependências.
- Separar recomendações de documentação, testes, refatoração, segurança, operação, UX e comportamento de produto.
- Gerar próximos passos que possam virar mudanças OpenSpec independentes e implementáveis.
- Não alterar código, schema, rotas, dependências ou UI nesta mudança.

## Capabilities

### New Capabilities

- `improvement-roadmap`: Define como melhorias devem ser sugeridas, priorizadas, justificadas e preparadas para implementação futura.

### Modified Capabilities

- Nenhuma.

## Impact

- Documentação afetada: novo artefato de roadmap de melhorias ou seção equivalente em relatório de análise.
- Código afetado: nenhum nesta mudança; a inspeção do código é somente leitura.
- APIs e comportamento em runtime: nenhum.
- Dependências: nenhuma.
