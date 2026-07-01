## Context

`bin/rails test` falhou porque o MySQL/MariaDB de teste não estava acessível em `127.0.0.1:3307`. O projeto já possui Docker Compose com MariaDB e documentação de bootstrap, mas falta um caminho único para preparar banco e executar validação local.

## Goals / Non-Goals

**Goals:**

- Definir um fluxo reprodutível para subir banco, preparar schema e rodar testes.
- Documentar pré-requisitos e variáveis de ambiente necessárias.
- Preferir comandos compatíveis com o Docker Compose existente.

**Non-Goals:**

- Adicionar cobertura de testes de negócio.
- Alterar regras financeiras ou comportamento da aplicação.
- Trocar adapter de banco.

## Decisions

- Usar Docker Compose como caminho principal.
  - Justificativa: o repositório já define MariaDB no Compose e README orienta esse fluxo.
  - Alternativa considerada: exigir banco local manual. Rejeitada por baixa reprodutibilidade.
- Manter validação em script/tarefa simples.
  - Justificativa: evita criar ferramenta nova para um fluxo operacional pequeno.
  - Alternativa considerada: adicionar CI completo. Rejeitada para manter escopo focado.

## Risks / Trade-offs

- Banco já existente com estado inconsistente -> Mitigação: documentar comandos de preparação/reset de teste.
- Ambiente local sem Docker -> Mitigação: manter instruções equivalentes para execução sem Docker.
- Script ficar defasado -> Mitigação: referenciar comandos Rails padrão e Compose já versionado.

## Migration Plan

Não há migração de dados. A mudança adiciona documentação e, se necessário, script/tarefa de validação local.

## Open Questions

- O comando padrão deve rodar via container `web` ou no Ruby local apontando para o banco do Compose?
