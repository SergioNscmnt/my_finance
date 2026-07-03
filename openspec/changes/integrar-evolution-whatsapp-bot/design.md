## Context

A aplicação já possui `User`, `Category` e `Transaction`, com valores financeiros criptografados via `encrypts_decimal`. Transações usam `kind` (`income`/`expense`), `payment_method` (`cash`/`credit_card`/`pix`), `occurred_on` como data e associação obrigatória com uma categoria do usuário.

A Evolution API será usada como ponte com WhatsApp. A documentação expõe configuração de webhook por instância, eventos como `MESSAGES_UPSERT` e envio de respostas por `POST /message/sendText/{instanceName}` com header `apikey`. O evento recebido precisa ser tratado como entrada externa não confiável.

## Goals / Non-Goals

**Goals:**

- Receber eventos da Evolution API em endpoint público autenticado por segredo compartilhado.
- Identificar o usuário pelo número de WhatsApp vinculado à aplicação.
- Registrar o payload recebido com idempotência por mensagem.
- Extrair dados financeiros de mensagens de texto em português.
- Criar transações usando os modelos e validações atuais.
- Responder no WhatsApp com sucesso, pendência de revisão ou erro compreensível.

**Non-Goals:**

- Implementar OCR completo de comprovantes/fotos na primeira entrega.
- Criar um fluxo de IA generativa obrigatório para interpretar mensagens.
- Alterar o armazenamento criptografado já implementado para valores financeiros.
- Persistir horário exato da transação enquanto o modelo possuir apenas `occurred_on`.
- Adicionar `ted` como enum separado sem uma mudança explícita de domínio de forma de pagamento.

## Decisions

- Criar `WhatsappAccount` para mapear `user_id`, `phone_number`, `instance_name` e status.
  - Justificativa: o webhook da Evolution identifica remetente/instância, mas a aplicação precisa resolver isso para um usuário antes de criar dados financeiros.
  - Alternativa considerada: procurar usuário por telefone no próprio `users`. Rejeitada porque `User` não tem telefone e o vínculo com instância/bot é domínio próprio da integração.

- Criar `EvolutionWebhookEvent` para armazenar evento bruto, `message_id`, remetente, status e erro de processamento.
  - Justificativa: webhooks podem ser repetidos; a aplicação precisa de auditoria mínima e idempotência antes de lançar transações.
  - Alternativa considerada: processar sem persistir evento. Rejeitada por risco de duplicidade e dificuldade de diagnóstico.

- Validar webhook por token/header configurado em `EVOLUTION_WEBHOOK_TOKEN`.
  - Justificativa: o endpoint será público e não pode depender de sessão Rails.
  - Alternativa considerada: aceitar qualquer evento vindo da URL. Rejeitada por permitir criação indevida de transações.

- Usar parser determinístico inicial para texto.
  - Justificativa: exemplos como “gastei R$ 30,00 no café da manhã no cartão de crédito” podem ser tratados com regras claras para valor, direção, categoria e pagamento, mantendo testes previsíveis.
  - Alternativa considerada: chamar LLM/OCR para todos os casos. Rejeitada no escopo inicial por custo, latência, privacidade e dependência externa adicional.

- Mapear `pix/ted` para `pix` no escopo inicial.
  - Justificativa: o enum atual não possui `ted`; criar novo valor altera domínio, views e filtros. A mensagem pode ser confirmada como “Pix/TED” no texto de retorno, mas a persistência inicial usa `pix`.
  - Alternativa considerada: adicionar `ted` ao enum agora. Rejeitada para reduzir escopo e evitar impacto em telas existentes.

- Persistir apenas `occurred_on` na primeira entrega.
  - Justificativa: o requisito cita data e hora, mas o modelo atual não tem campo de hora. A integração deve usar a data do evento/mensagem para `occurred_on` e preservar o horário no evento bruto.
  - Alternativa considerada: adicionar `occurred_at`. Rejeitada para evitar reescrever regras existentes de dashboard, fatura e orçamento.

- Criar transação somente quando houver confiança mínima.
  - Justificativa: valor, direção, categoria e usuário são obrigatórios para evitar lançamentos errados.
  - Alternativa considerada: sempre criar como “Outras despesas/receitas”. Rejeitada porque silenciosamente deteriora os dados financeiros.

## Risks / Trade-offs

- Mensagem ambígua ou incompleta -> Responder solicitando informação faltante e não criar transação.
- Categoria inexistente para o usuário -> Usar correspondência por nome/palavra-chave; se não houver categoria confiável, pedir revisão.
- Evento duplicado da Evolution API -> Bloquear por índice único de `message_id` por instância/remetente.
- Número não vinculado -> Registrar evento como ignorado/não autorizado e responder apenas se isso for explicitamente permitido.
- Foto sem texto interpretável -> Registrar recebimento e responder que análise de imagem ainda não está disponível no fluxo inicial.
- Token de webhook vazado -> Permitir rotação por variável de ambiente e rejeitar eventos sem token válido.

## Migration Plan

1. Adicionar migrations e modelos `WhatsappAccount` e `EvolutionWebhookEvent`.
2. Configurar variáveis de ambiente da Evolution API.
3. Criar endpoint de webhook sem CSRF, com validação de token.
4. Implementar parser e processador com testes unitários.
5. Integrar criação de transação e resposta via Evolution API.
6. Configurar webhook na Evolution API para `MESSAGES_UPSERT`.
7. Validar manualmente com mensagens reais em ambiente de desenvolvimento.

Rollback: desabilitar o webhook na Evolution API, remover/ignorar variáveis de ambiente e manter eventos já recebidos sem processar novos lançamentos.

## Open Questions

- O usuário quer uma tela administrativa para cadastrar números de WhatsApp ou o vínculo inicial pode ser criado por seed/console?
- Mensagens de números não vinculados devem receber resposta automática ou permanecer silenciosas?
- O domínio da aplicação deve ganhar `ted` como forma de pagamento distinta em uma mudança posterior?
- A etapa de foto deve usar OCR local, serviço externo ou modelo multimodal quando entrar no escopo?
