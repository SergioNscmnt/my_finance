## Context

MyFinance é uma aplicação Rails 7.1 para finanças pessoais, usando MariaDB no desenvolvimento local com Docker, TailwindCSS v4, Turbo/Stimulus e notas de deploy orientadas ao Render. O domínio visível inclui transações de fluxo de caixa, categorias, orçamentos por categoria, faturas de cartão de crédito, carteiras de investimento, instrumentos de mercado, cotações, ordens, dividendos, posições, candles, taxas de câmbio e lançamentos contábeis.

A mudança é apenas documental. Ela define como inspecionar e reportar sobre o repositório sem alterar comportamento da aplicação, schema do banco, rotas, dependências ou configuração de runtime.

## Goals / Non-Goals

**Goals:**

- Produzir uma visão factual da arquitetura e do domínio com base no repositório atual.
- Identificar riscos de implementação, testes ausentes, fronteiras de responsabilidade pouco claras, premissas de deploy e preocupações do modelo de dados.
- Priorizar recomendações para que trabalhos seguintes possam virar mudanças OpenSpec concretas ou tarefas de implementação.
- Manter os achados rastreáveis a arquivos, rotas, models, schema ou configurações observadas no repositório.

**Non-Goals:**

- Implementar correções de código ou refatorações durante a análise.
- Adicionar testes, dependências, CI ou automação de deploy.
- Redesenhar a experiência do produto ou alterar regras de cálculo financeiro.
- Executar auditorias de dados de produção ou testes externos de segurança.

## Decisions

- Usar uma análise documental antes de refatorações imediatas.
  - Justificativa: o projeto atravessa vários subdomínios financeiros, e edições prematuras de código poderiam misturar descoberta com mudanças de comportamento.
  - Alternativa considerada: corrigir problemas conforme forem encontrados. Rejeitada porque dificulta a revisão e pode esconder decisões de produto dentro de limpeza técnica.
- Estruturar o relatório por área do sistema e severidade.
  - Justificativa: aplicações Rails são mais fáceis de analisar por rotas/controllers, models/schema, views, configuração e testes.
  - Alternativa considerada: um log de auditoria puramente cronológico. Rejeitada porque é menos útil para planejar trabalhos seguintes.
- Tratar a ausência de testes automatizados como achado de primeira classe.
  - Justificativa: o README informa que testes não estão configurados, e lógica financeira como parcelamento e impacto mensal é sensível a regressões.
  - Alternativa considerada: deixar a postura de testes para uma revisão separada. Rejeitada porque a priorização de riscos ficaria incompleta.

## Risks / Trade-offs

- Contexto incompleto do repositório -> Mitigação: rotular claramente achados baseados apenas nos arquivos inspecionados e listar perguntas abertas para premissas não verificadas.
- A análise fica ampla demais -> Mitigação: manter o relatório focado em arquitetura, risco de comportamento, integridade de dados, setup operacional e próximas mudanças de alto valor.
- Achados pouco acionáveis -> Mitigação: exigir que cada risco inclua evidência, impacto, severidade e uma próxima ação recomendada concreta.
- A documentação fica defasada após mudanças de código -> Mitigação: tratar o relatório como um retrato datado e converter recomendações aceitas em mudanças OpenSpec menores.

## Migration Plan

Nenhuma migração é necessária. Esta mudança apenas adiciona documentação de análise e tarefas de implementação para produzir essa documentação.

## Open Questions

- Onde o relatório final de análise deve ficar: `docs/`, `openspec/changes/analisar-projeto/` ou outra convenção do projeto?
- A primeira análise deve incluir screenshots de UI e verificação manual no navegador, ou ficar limitada à inspeção estática do repositório?
- O comportamento do domínio de investimentos deve ser analisado no mesmo relatório do fluxo de caixa pessoal, ou separado em mudanças posteriores?
