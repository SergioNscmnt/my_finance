## Context

A mudança `integrar-evolution-whatsapp-bot` adicionou `WhatsappAccount`, `EvolutionWebhookEvent`, `Evolution::Client` e webhook público para a Evolution API. O bot só processa mensagens de números vinculados, mas ainda não existe fluxo de UI para o usuário cadastrar e testar esse vínculo.

A página `Minha conta` já centraliza dados do usuário autenticado e é o lugar mais próximo para preferências pessoais. O modelo `WhatsappAccount` já normaliza telefone para dígitos e possui unicidade por `instance_name` e `phone_number`.

## Goals / Non-Goals

**Goals:**

- Permitir que o usuário autenticado cadastre um ou mais vínculos WhatsApp.
- Exibir vínculos existentes com telefone, instância, status e último uso.
- Permitir ativar/desativar e remover vínculos do próprio usuário.
- Permitir envio de mensagem de teste usando `Evolution::Client`.
- Manter todas as ações escopadas ao `current_user`.
- Documentar como configurar webhook e variáveis da Evolution API.

**Non-Goals:**

- Criar área admin multiusuário.
- Criar QR Code/conexão de instância Evolution dentro da aplicação.
- Alterar parser, webhook ou regras de criação de transação.
- Exibir payloads completos de eventos na UI.
- Implementar confirmação interativa de lançamentos via WhatsApp.

## Decisions

- Adicionar gerenciamento dentro de `account/show`.
  - Justificativa: vínculo WhatsApp é uma preferência do usuário, e a tela de conta já existe.
  - Alternativa considerada: criar menu lateral dedicado. Rejeitada por ampliar navegação para um fluxo pequeno.

- Criar `WhatsappAccountsController` autenticado com ações `create`, `update`, `destroy` e `test_message`.
  - Justificativa: mantém o CRUD do vínculo separado da atualização de nome/e-mail/senha em `AccountsController`.
  - Alternativa considerada: colocar tudo em `AccountsController`. Rejeitada por misturar responsabilidades e dificultar testes.

- Usar `current_user.whatsapp_accounts` em todas as queries.
  - Justificativa: impede acesso cruzado por ID entre usuários.
  - Alternativa considerada: buscar `WhatsappAccount.find(params[:id])` e validar depois. Rejeitada por aumentar risco de vazamento.

- Manter remoção física do vínculo, preservando eventos com `dependent: :nullify`.
  - Justificativa: o modelo já foi criado para manter histórico dos eventos sem bloquear remoção da conta.
  - Alternativa considerada: soft delete. Rejeitada para evitar nova coluna enquanto ativar/desativar já cobre suspensão.

- Mensagem de teste como ação explícita por vínculo.
  - Justificativa: valida configuração real da Evolution API e número cadastrado sem criar transações.
  - Alternativa considerada: enviar teste automaticamente ao cadastrar. Rejeitada porque ambientes locais podem não estar configurados.

## Risks / Trade-offs

- Número cadastrado em formato inconsistente -> Mitigação: normalizar para dígitos no modelo e mostrar formato legível na UI.
- Usuário cadastrar instância errada -> Mitigação: exibir instância no card e permitir edição/recriação do vínculo.
- Evolution API sem configuração -> Mitigação: exibir erro controlado ao testar, sem impedir cadastro do vínculo.
- Usuário remover vínculo com eventos históricos -> Mitigação: eventos ficam preservados com `whatsapp_account_id` nulo e `user_id` quando já processados.
- Bot não responder após cadastro porque webhook externo não foi configurado -> Mitigação: documentar URL, token/header e evento `MESSAGES_UPSERT`.

## Migration Plan

1. Adicionar rotas autenticadas para `whatsapp_accounts`.
2. Criar controller com escopo por `current_user`.
3. Renderizar seção de WhatsApp em `account/show` com formulário, lista e ações.
4. Reutilizar `Evolution::Client` para mensagem de teste.
5. Adicionar helpers/labels mínimos para telefone e status.
6. Cobrir controller/modelo com testes.
7. Atualizar README com configuração operacional.

Rollback: remover rotas/views/controller sem alterar tabelas já existentes; o webhook continuará funcionando para vínculos criados por console.

## Open Questions

- A instância padrão deve ser preenchida automaticamente por `EVOLUTION_INSTANCE_NAME` no formulário?
- O usuário final deve poder cadastrar mais de um número por instância ou devemos limitar a um vínculo ativo por usuário?
