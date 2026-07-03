## Why

O usuário quer registrar receitas e despesas a partir de mensagens e fotos enviadas pelo WhatsApp, reduzindo atrito no lançamento manual de transações. A Evolution API fornece webhooks de mensagens recebidas e endpoints de resposta, mas a aplicação precisa de uma camada segura para receber, interpretar, validar e persistir esses dados financeiros.

## What Changes

- Adicionar integração com Evolution API para receber eventos `MESSAGES_UPSERT` por webhook.
- Criar vínculo entre número de WhatsApp/instância Evolution e usuário da aplicação.
- Interpretar mensagens de texto financeiras em português para extrair tipo da transação, valor, categoria, forma de pagamento e data de referência.
- Persistir eventos recebidos com idempotência para evitar lançamentos duplicados.
- Criar transações a partir de mensagens com confiança suficiente e enviar resposta de confirmação pelo WhatsApp.
- Preparar o fluxo para anexos/imagens, mantendo OCR e extração visual como fase separada caso não haja parser confiável disponível.
- Não alterar o armazenamento criptografado de valores já existente; a nova entrada deve usar os modelos atuais de transação.

## Capabilities

### New Capabilities

- `evolution-whatsapp-transaction-bot`: Define como a aplicação recebe eventos da Evolution API, identifica o usuário, interpreta mensagens financeiras e cria transações.

### Modified Capabilities

- Nenhuma.

## Impact

- Rotas/controladores: novo endpoint público para webhook da Evolution API com validação por token/header.
- Modelos e banco: novas tabelas para contas WhatsApp vinculadas ao usuário e eventos de webhook processados.
- Serviços: parser de mensagens financeiras, processador de webhook e cliente para envio de respostas via Evolution API.
- Configuração: novas variáveis `EVOLUTION_API_BASE_URL`, `EVOLUTION_API_KEY`, `EVOLUTION_INSTANCE_NAME` e `EVOLUTION_WEBHOOK_TOKEN`.
- Segurança: validação de origem por segredo compartilhado, idempotência por `message_id` e escopo obrigatório por usuário.
- Limitações conhecidas: o modelo atual armazena `occurred_on` como data, não horário; `payment_method` possui `cash`, `credit_card` e `pix`, mas não `ted`.
