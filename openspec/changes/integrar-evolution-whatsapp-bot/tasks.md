## 1. Banco e modelos

- [x] 1.1 Criar migration e modelo `WhatsappAccount` com usuário, telefone, instância, status e índices de unicidade.
- [x] 1.2 Criar migration e modelo `EvolutionWebhookEvent` com evento, instância, remetente, identificador da mensagem, payload JSON, status, erro e timestamps de processamento.
- [x] 1.3 Adicionar associações em `User` para contas WhatsApp e eventos quando aplicável.
- [x] 1.4 Criar validações e índices para impedir duplicidade de mensagem por instância/remetente.

## 2. Configuração e cliente Evolution

- [x] 2.1 Documentar variáveis `EVOLUTION_API_BASE_URL`, `EVOLUTION_API_KEY`, `EVOLUTION_INSTANCE_NAME` e `EVOLUTION_WEBHOOK_TOKEN`.
- [x] 2.2 Criar cliente `Evolution::Client` para envio de texto via `/message/sendText/{instanceName}`.
- [x] 2.3 Tratar ausência de configuração com erro controlado sem quebrar o processamento do webhook.

## 3. Webhook

- [x] 3.1 Adicionar rota pública `POST /webhooks/evolution`.
- [x] 3.2 Criar controller sem CSRF para o webhook e validar segredo compartilhado.
- [x] 3.3 Extrair com tolerância `event`, `instance`, `message_id`, telefone do remetente, texto, legenda e tipo de mídia a partir do payload da Evolution API.
- [x] 3.4 Persistir evento recebido antes do processamento de negócio.
- [x] 3.5 Ignorar mensagens enviadas pelo próprio bot e eventos diferentes de `MESSAGES_UPSERT`.

## 4. Parser e classificação

- [x] 4.1 Criar parser de valores monetários em português, aceitando formatos como `R$ 30,00`, `5800,00` e `5.800,00`.
- [x] 4.2 Classificar `income` e `expense` por palavras-chave como `recebi`, `salário`, `gastei`, `paguei` e `comprei`.
- [x] 4.3 Resolver categoria por correspondência com categorias do usuário e mapa inicial de palavras-chave.
- [x] 4.4 Resolver forma de pagamento para `credit_card`, `pix` ou `cash`, mapeando `pix/ted` para `pix` no escopo inicial.
- [x] 4.5 Retornar resultado estruturado com confiança e erros de campos faltantes.

## 5. Processamento de transações

- [x] 5.1 Criar serviço `Evolution::WebhookProcessor` para orquestrar identificação do usuário, parser, criação de transação e resposta.
- [x] 5.2 Criar transação somente quando usuário, valor, tipo, categoria e pagamento forem válidos.
- [x] 5.3 Marcar eventos como `processed`, `pending`, `ignored` ou `failed`.
- [x] 5.4 Enviar confirmação pelo WhatsApp quando a transação for criada.
- [x] 5.5 Enviar solicitação de ajuste quando a mensagem for ambígua ou incompleta.
- [x] 5.6 Registrar mídia sem texto interpretável sem criar transação automática.

## 6. Testes e validação

- [x] 6.1 Testar modelos e índices de idempotência.
- [x] 6.2 Testar parser com exemplos de despesa, receita, cartão, pix/ted e mensagens incompletas.
- [x] 6.3 Testar webhook com token válido, token inválido, mensagem duplicada e número não vinculado.
- [x] 6.4 Testar criação de transação garantindo escopo do usuário e uso das validações atuais.
- [x] 6.5 Rodar suite Rails e validar manualmente um payload real ou fixture da Evolution API.
