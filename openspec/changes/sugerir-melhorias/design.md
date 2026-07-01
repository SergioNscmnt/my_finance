## Context

O projeto já possui uma mudança de análise (`analisar-projeto`) que define como mapear arquitetura, riscos e lacunas. Esta mudança complementa esse trabalho criando um formato de roadmap para transformar os achados em sugestões priorizadas, comparáveis e prontas para virar mudanças OpenSpec menores.

O foco é documental e decisório. A implementação deve produzir uma lista clara de melhorias, não aplicar as melhorias diretamente.

## Goals / Non-Goals

**Goals:**

- Consolidar melhorias técnicas e de produto observáveis a partir da análise do projeto.
- Priorizar recomendações por impacto, esforço, risco reduzido, dependências e urgência.
- Separar melhorias por tipo: testes, arquitetura, dados, segurança, operação, UX, documentação e regras de negócio.
- Converter as recomendações mais importantes em candidatos claros para próximas mudanças OpenSpec.

**Non-Goals:**

- Corrigir código, rotas, schema, views ou dependências nesta mudança.
- Substituir a análise técnica detalhada definida em `analisar-projeto`.
- Decidir regras financeiras sem validação de produto.
- Criar um processo pesado de gestão de roadmap fora do repositório.

## Decisions

- Usar uma matriz simples de prioridade.
  - Justificativa: o projeto precisa de recomendações acionáveis sem burocracia excessiva.
  - Alternativa considerada: um scoring numérico complexo. Rejeitada porque pode parecer preciso sem dados suficientes.
- Vincular cada sugestão a evidência do repositório ou a achado da análise.
  - Justificativa: recomendações sem evidência são difíceis de revisar e priorizar.
  - Alternativa considerada: listar ideias gerais de melhoria. Rejeitada porque não cria uma fila técnica confiável.
- Separar execução em mudanças OpenSpec menores.
  - Justificativa: melhorias como testes, refatoração de domínio financeiro e ajustes operacionais têm riscos e validações diferentes.
  - Alternativa considerada: implementar várias melhorias em um único pacote. Rejeitada porque aumenta o risco de regressão e dificulta revisão.

## Risks / Trade-offs

- Priorização subjetiva -> Mitigação: explicitar impacto, esforço, evidência e risco reduzido em cada sugestão.
- Roadmap amplo demais -> Mitigação: limitar a primeira versão às melhorias mais relevantes e agrupar o restante como backlog.
- Recomendações duplicadas com `analisar-projeto` -> Mitigação: usar a análise como fonte e transformar achados em ações, sem repetir inventário completo.
- Falta de decisão de produto -> Mitigação: marcar recomendações que dependem de validação de regra de negócio como pendentes de decisão.

## Migration Plan

Nenhuma migração é necessária. A mudança apenas adiciona artefatos de proposta, design, especificação e tarefas para produzir um roadmap de melhorias.

## Open Questions

- O roadmap final deve ficar em `docs/`, dentro da mudança OpenSpec ou em ambos?
- A primeira priorização deve focar em estabilidade técnica ou em evolução funcional do produto?
- As recomendações de investimento devem ficar no mesmo roadmap das finanças pessoais ou em uma trilha separada?
