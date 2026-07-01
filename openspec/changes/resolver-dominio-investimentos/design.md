## Context

O workspace mantém models, migrations e serviços de investimentos, mas as rotas atuais não expõem essa superfície e há remoções não commitadas de controllers/views/serviços relacionados. A mudança deve resolver a direção do domínio antes de novos trabalhos.

## Goals / Non-Goals

**Goals:**

- Inventariar o domínio de investimentos existente.
- Escolher uma estratégia: remover, congelar ou reintroduzir.
- Definir plano seguro para código, schema e documentação.

**Non-Goals:**

- Implementar produto completo de investimentos sem decisão prévia.
- Alterar fluxo de caixa pessoal.
- Migrar dados reais sem plano separado.

## Decisions

- Separar decisão de domínio de implementação.
  - Justificativa: remover e reintroduzir exigem planos opostos.
  - Alternativa considerada: apagar código órfão imediatamente. Rejeitada por risco de perder intenção de produto.
- Inventariar antes de migrar schema.
  - Justificativa: tabelas e serviços ainda podem ter dependências indiretas.
  - Alternativa considerada: decidir só por rotas atuais. Rejeitada porque o schema mantém domínio completo.

## Risks / Trade-offs

- Decisão sem alinhamento de produto -> Mitigação: registrar opções e impactos antes da implementação.
- Remoção destruir dados úteis -> Mitigação: separar migração destrutiva em mudança específica.
- Reintrodução ampliar escopo -> Mitigação: definir MVP e testes mínimos se reativado.

## Migration Plan

Inventariar, decidir estratégia e só então executar remoção, congelamento documentado ou reintrodução em mudança posterior.

## Open Questions

- Investimentos ainda fazem parte do produto desejado?
- Há dados reais de investimento que precisam ser preservados?
