## Context

O layout carrega Chart.js, Tom Select e Flatpickr por CDN, e a CSP está comentada. A mudança precisa decidir se os assets ficam externos com política explícita ou entram no pipeline local.

## Goals / Non-Goals

**Goals:**

- Tornar a origem dos assets frontend intencional e documentada.
- Configurar CSP compatível com a decisão.
- Validar componentes dependentes desses assets.

**Non-Goals:**

- Redesenhar componentes frontend.
- Trocar Stimulus/Turbo/importmap.
- Alterar regras de negócio.

## Decisions

- Avaliar vendorização/pinning local antes de manter CDN.
  - Justificativa: dependências críticas de UI não deveriam quebrar por indisponibilidade externa sem decisão explícita.
  - Alternativa considerada: apenas liberar CDN na CSP. Aceitável se vendorização tiver custo maior, mas deve ser documentado.
- Configurar CSP de forma incremental.
  - Justificativa: CSP mal configurada pode quebrar assets e scripts inline.
  - Alternativa considerada: aplicar política restritiva de uma vez. Rejeitada por risco operacional.

## Risks / Trade-offs

- CSP bloquear UI -> Mitigação: validar charts, selects, datepicker, tema e modais.
- Vendorização aumentar manutenção -> Mitigação: documentar versões e processo de atualização.
- CDN manter risco externo -> Mitigação: configurar CSP explícita e aceitar trade-off conscientemente.

## Migration Plan

Escolher origem dos assets, ajustar layout/importmap/assets, habilitar CSP compatível e validar componentes.

## Open Questions

- O projeto prefere dependências frontend locais ou CDN com CSP explícita?
