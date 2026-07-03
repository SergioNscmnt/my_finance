## 1. Rotas e controller

- [x] 1.1 Adicionar rotas autenticadas para criar, atualizar, remover e testar vínculos WhatsApp.
- [x] 1.2 Criar `WhatsappAccountsController` escopando todas as buscas por `current_user.whatsapp_accounts`.
- [x] 1.3 Implementar criação com normalização/validação e retorno para a página de conta.
- [x] 1.4 Implementar ativação/desativação do vínculo.
- [x] 1.5 Implementar remoção do vínculo preservando eventos/transações existentes.
- [x] 1.6 Implementar envio de mensagem de teste com tratamento controlado de configuração ausente ou falha da Evolution API.

## 2. Interface de conta

- [x] 2.1 Carregar vínculos WhatsApp e novo formulário em `AccountsController#show`.
- [x] 2.2 Adicionar seção "WhatsApp" em `app/views/accounts/show.html.erb`.
- [x] 2.3 Exibir telefone, instância, status, último uso e resumo de eventos por vínculo.
- [x] 2.4 Adicionar ações visíveis para ativar/desativar, enviar teste e remover.
- [x] 2.5 Exibir erros de validação do vínculo sem quebrar o formulário principal da conta.

## 3. Documentação

- [x] 3.1 Atualizar README com variáveis da Evolution API, endpoint `/webhooks/evolution` e evento `MESSAGES_UPSERT`.
- [x] 3.2 Documentar como cadastrar vínculo e enviar mensagem de teste pela UI.

## 4. Testes e validação

- [x] 4.1 Testar criação de vínculo por usuário autenticado.
- [x] 4.2 Testar que usuário não lista, altera, testa ou remove vínculo de outro usuário.
- [x] 4.3 Testar ativação/desativação e remoção.
- [x] 4.4 Testar mensagem de teste com cliente Evolution mockado ou configuração ausente.
- [x] 4.5 Rodar suite Rails completa.
