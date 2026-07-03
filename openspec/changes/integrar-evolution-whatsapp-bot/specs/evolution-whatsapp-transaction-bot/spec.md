## ADDED Requirements

### Requirement: Webhook autenticado da Evolution API
O sistema DEVE expor um endpoint público para receber eventos da Evolution API e DEVE rejeitar requisições sem segredo válido.

#### Scenario: Evento com token válido é aceito
- **WHEN** a Evolution API envia um evento `MESSAGES_UPSERT` com o segredo configurado
- **THEN** o sistema registra o evento e inicia o processamento da mensagem

#### Scenario: Evento sem token válido é rejeitado
- **WHEN** uma requisição chega ao webhook sem o segredo correto
- **THEN** o sistema rejeita a requisição sem criar transações

### Requirement: Idempotência de mensagens recebidas
O sistema DEVE impedir que a mesma mensagem do WhatsApp crie mais de uma transação.

#### Scenario: Mensagem duplicada é recebida
- **WHEN** o webhook recebe novamente um evento com o mesmo identificador de mensagem, instância e remetente
- **THEN** o sistema mantém apenas um registro processável e não cria transação duplicada

### Requirement: Vínculo de WhatsApp com usuário
O sistema DEVE criar transações somente para números de WhatsApp vinculados a um usuário ativo da aplicação.

#### Scenario: Número vinculado envia mensagem financeira
- **WHEN** uma mensagem financeira é recebida de um número vinculado
- **THEN** o sistema processa a mensagem no escopo do usuário correspondente

#### Scenario: Número não vinculado envia mensagem
- **WHEN** uma mensagem é recebida de um número sem vínculo
- **THEN** o sistema não cria transação e registra o evento como não autorizado ou ignorado

### Requirement: Extração de transação por texto
O sistema DEVE extrair de mensagens em português os campos mínimos para criar uma transação: tipo, valor, categoria, forma de pagamento e data.

#### Scenario: Despesa de alimentação no cartão
- **WHEN** o usuário envia “gastei R$ 30,00 no café da manhã no cartão de crédito”
- **THEN** o sistema identifica uma despesa de R$ 30,00 na categoria Alimentação, forma de pagamento cartão de crédito e data do evento

#### Scenario: Receita de salário por Pix ou TED
- **WHEN** o usuário envia “recebi o salário no valor de 5800,00”
- **THEN** o sistema identifica uma receita de R$ 5.800,00 na categoria Salário, forma de pagamento Pix e data do evento

### Requirement: Criação segura de transações
O sistema DEVE criar uma transação somente quando valor, tipo, categoria e usuário forem identificados com confiança suficiente.

#### Scenario: Mensagem completa cria transação
- **WHEN** uma mensagem possui dados mínimos válidos e categoria pertencente ao usuário
- **THEN** o sistema cria uma transação usando as validações atuais de `Transaction`

#### Scenario: Mensagem incompleta não cria transação
- **WHEN** uma mensagem não permite identificar valor, tipo ou categoria
- **THEN** o sistema não cria transação e marca o evento como pendente ou rejeitado

### Requirement: Resposta ao usuário pelo WhatsApp
O sistema DEVE enviar uma resposta pelo WhatsApp informando se a transação foi registrada ou se há dados faltantes.

#### Scenario: Transação criada com sucesso
- **WHEN** o sistema cria uma transação a partir da mensagem recebida
- **THEN** o usuário recebe confirmação com tipo, valor, categoria, forma de pagamento e data

#### Scenario: Transação não criada por ambiguidade
- **WHEN** o sistema não consegue criar a transação por dados insuficientes
- **THEN** o usuário recebe uma mensagem solicitando a informação faltante

### Requirement: Tratamento inicial de mídia
O sistema DEVE aceitar eventos que contenham mídia sem tentar criar transação automaticamente quando não houver texto interpretável.

#### Scenario: Foto sem legenda financeira
- **WHEN** o usuário envia uma foto sem texto ou legenda suficiente
- **THEN** o sistema registra o evento e responde que a análise de imagem ainda não está disponível no fluxo inicial
