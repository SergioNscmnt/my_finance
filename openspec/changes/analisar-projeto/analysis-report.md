# Análise do projeto MyFinance

Data da análise: 2026-06-03  
Escopo: inspeção estática do workspace atual, com uma tentativa de execução de `bin/rails test`.

## Resumo executivo

MyFinance é uma aplicação Rails 7.1.6 em Ruby 3.0.2 para controle financeiro pessoal. O produto exposto no workspace atual cobre autenticação simples, dashboard, transações, categorias, orçamentos por categoria, faturas de cartão de crédito e importação de extrato PDF do Banco do Brasil. O repositório também mantém um conjunto relevante de modelos, migrations e serviços para investimentos e dados de mercado, mas essas telas/controllers aparecem removidos ou não roteados no estado atual do workspace.

Os principais riscos estão concentrados em três frentes: ausência de testes efetivos para regras financeiras, divergência entre domínio persistido e UI exposta, e fragilidade operacional por diferenças entre MariaDB local e PostgreSQL em produção. A aplicação tem uma base funcional clara, mas precisa consolidar limites de domínio e transformar cálculos críticos em serviços testados antes de novas funcionalidades grandes.

## Inventário técnico

### Stack e execução

- Rails 7.1.6, Ruby 3.0.2, importmap, Turbo, Stimulus, Sprockets e TailwindCSS v4. Evidência: `Gemfile`, `.ruby-version`, `config/importmap.rb`, `app/javascript/application.js`.
- Desenvolvimento local usa MariaDB 10.11 via Docker Compose, com app Rails na porta 3000 e banco exposto na 3307. Evidência: `README.md`, `docker-compose.yml`, `config/database.yml`.
- Produção aceita `DATABASE_URL` e inclui `pg` no grupo de produção, enquanto desenvolvimento/teste usam `mysql2`. Evidência: `Gemfile`, `config/database.yml`, `README.md`.
- Dockerfile instala `pdftotext` via `poppler-utils`, Tailwind CLI manualmente e roda assets precompile no build. Evidência: `Dockerfile`.
- Entrypoint remove `server.pid` e roda `db:migrate` antes de iniciar o servidor Rails. Evidência: `bin/docker-entrypoint`.

### Rotas e superfície funcional

- Rotas públicas/autenticadas atuais: criação de usuário, sessão, conta, categorias, orçamentos, pagamento de fatura, CRUD de transações, importação de PDF e dashboard. Evidência: `config/routes.rb`.
- Não há rotas atuais para carteiras, ativos, ordens, posições, dividendos, cotações ou telas de investimentos. Evidência: `config/routes.rb`.
- O `git status` mostra remoções não commitadas de controllers/views/serviços de investimento, então esta análise considera o workspace atual e não necessariamente a intenção final do branch.

### Domínio e persistência

- Domínio de fluxo de caixa: `User`, `Category`, `Transaction`, `CategoryBudget` e `CreditCardInvoice`. Evidência: `app/models/user.rb`, `app/models/category.rb`, `app/models/transaction.rb`, `app/models/category_budget.rb`, `app/models/credit_card_invoice.rb`.
- Domínio de investimentos persistido: `Wallet`, `Asset`, `InvestmentTransaction`, `Dividend`, `InvestmentGoal`, `AllocationTarget`, `Portfolio`, `CashAccount`, `Position`, `Order`, `LedgerEntry`, `Quote`, `Candle`, `FxRate` e `MarketInstrument`. Evidência: `app/models/*.rb`, `db/schema.rb`.
- `Transaction` concentra regras de parcelamento, impacto mensal e início de mês de cobrança de cartão. Evidência: `app/models/transaction.rb`.
- `Category` concentra regras de categoria de cartão, dia de fechamento/vencimento e unicidade customizada para categorias não-cartão. Evidência: `app/models/category.rb`.
- `CreditCardInvoiceSyncer` recalcula faturas com base nas transações de cartão e preserva faturas pagas. Evidência: `app/services/credit_card_invoice_syncer.rb`.
- `StatementImports::BancoDoBrasilPdfImporter` extrai texto de PDF com `pdftotext`, interpreta linhas por regex e cria transações de cartão. Evidência: `app/services/statement_imports/banco_do_brasil_pdf_importer.rb`.

### Controllers e UI

- `DashboardController` monta totais, séries mensais, categorias, orçamento e faturas diretamente no controller. Evidência: `app/controllers/dashboard_controller.rb`.
- `TransactionsController` duplica parte relevante dos cálculos de dashboard para responder Turbo Stream após create/update/destroy. Evidência: `app/controllers/transactions_controller.rb`.
- Autenticação é baseada em `has_secure_password` e `session[:user_id]`, sem autorização externa. Evidência: `app/models/user.rb`, `app/controllers/application_controller.rb`, `app/controllers/sessions_controller.rb`.
- Views usam ERB + Tailwind e dependem de Stimulus para modal, tema, máscara de moeda, menu, dropdown, charts e selects. Evidência: `app/views/layouts/application.html.erb`, `app/javascript/application.js`, `app/javascript/controllers/*.js`.
- Chart.js, Tom Select e Flatpickr são carregados por CDN no layout. Evidência: `app/views/layouts/application.html.erb`.

### Testes e validação

- Há estrutura Minitest gerada, fixtures e alguns arquivos de teste, mas `test/models/category_test.rb` e `test/models/transaction_test.rb` contêm apenas placeholders comentados. Evidência: `test/test_helper.rb`, `test/models/category_test.rb`, `test/models/transaction_test.rb`.
- Não há `.github` encontrado nesta inspeção, então não há sinal de CI versionado no workspace atual.
- `bin/rails test` foi executado e falhou antes de rodar a suíte por conexão indisponível com MySQL em `127.0.0.1:3307`. Isso indica que a validação local depende do serviço de banco estar previamente ativo.

## Achados de risco

### Alta: regras financeiras críticas sem testes efetivos

- Evidência: `app/models/transaction.rb`, `app/models/category.rb`, `app/services/credit_card_invoice_syncer.rb`, `test/models/transaction_test.rb`, `test/models/category_test.rb`.
- Impacto: mudanças em parcelamento, mês de cobrança, vencimento de fatura ou orçamento podem gerar saldos incorretos sem regressão automatizada.
- Justificativa: cálculos como `monthly_amount_for`, `billing_start_month`, `due_date_for_billing_month` e sincronização de faturas afetam diretamente os números exibidos no dashboard.
- Próxima ação: criar testes unitários para `Transaction`, `Category`, `CreditCardInvoiceSyncer` e importação de PDF antes de refatorar regras.

### Alta: diferença de banco entre desenvolvimento/teste e produção

- Evidência: `Gemfile`, `config/database.yml`, `db/schema.rb`, `Dockerfile`, `bin/docker-entrypoint`.
- Impacto: schema e migrations gerados em MySQL podem não se comportar igual em PostgreSQL no Render, especialmente com opções de charset/collation e tipos JSON.
- Justificativa: o próprio entrypoint evita `db:prepare` por reconhecer que `schema.rb` gerado no MySQL pode quebrar no PostgreSQL.
- Próxima ação: decidir oficialmente se produção deve usar PostgreSQL ou MariaDB; se PostgreSQL continuar, validar migrations em PostgreSQL em CI.

### Alta: domínio de investimentos persistido sem superfície funcional atual

- Evidência: `db/schema.rb`, `app/models/asset.rb`, `app/models/portfolio.rb`, `app/services/market_data/*`, `config/routes.rb`, `git status --short`.
- Impacto: o projeto mantém código e tabelas de investimento que podem estar órfãos, parcialmente removidos ou fora do produto navegável.
- Justificativa: rotas atuais não expõem investimentos, enquanto o workspace mostra remoções de controllers/views relacionadas a investimentos.
- Próxima ação: abrir mudança específica para decidir se o domínio de investimentos será removido, pausado ou reintroduzido com rotas/testes.

### Média: cálculos de dashboard duplicados em controllers

- Evidência: `app/controllers/dashboard_controller.rb`, `app/controllers/transactions_controller.rb`, `app/controllers/category_budgets_controller.rb`.
- Impacto: correções em métricas, orçamento, gráficos ou faturas podem ser feitas em um controller e esquecidas em outro.
- Justificativa: `TransactionsController#dashboard_data` replica lógica de `DashboardController#index` para Turbo Streams.
- Próxima ação: extrair um serviço/query object de dashboard com contrato testado.

### Média: dependências de CDN sem CSP aplicada

- Evidência: `app/views/layouts/application.html.erb`, `config/initializers/content_security_policy.rb`.
- Impacto: indisponibilidade de CDN quebra charts/selects/datepicker; CSP comentada reduz proteção contra scripts não esperados.
- Justificativa: Chart.js, Tom Select e Flatpickr são carregados externamente, e a política CSP está inteiramente comentada.
- Próxima ação: pin/vendorizar dependências críticas ou configurar CSP explícita com nonces e domínios permitidos.

### Média: importação de PDF é específica e frágil

- Evidência: `app/services/statement_imports/banco_do_brasil_pdf_importer.rb`, `app/controllers/transactions_controller.rb`.
- Impacto: pequenas mudanças no layout do PDF do banco podem gerar importações incompletas, duplicadas ou incorretas.
- Justificativa: parsing depende de regex e de `pdftotext`; duplicidade é detectada por busca com todos os atributos da transação.
- Próxima ação: adicionar fixtures de texto/PDF e testes de parsing, parcelamento e idempotência.

### Média: autorização é simples e dependente de escopo manual

- Evidência: `app/controllers/application_controller.rb`, `app/controllers/categories_controller.rb`, `app/controllers/transactions_controller.rb`, `app/controllers/category_budgets_controller.rb`.
- Impacto: novos controllers podem esquecer `current_user.*` e vazar dados entre usuários.
- Justificativa: não há camada explícita de autorização; a segurança depende de cada controller usar o escopo correto.
- Próxima ação: criar padrão documentado e testes de isolamento por usuário para cada recurso sensível.

### Baixa: testes existem, mas não são executáveis sem banco local ativo

- Evidência: `bin/rails test`, `config/database.yml`, `docker-compose.yml`.
- Impacto: contribuição local fica mais lenta e regressões podem passar por falta de ambiente pronto.
- Justificativa: a suíte falhou antes de executar testes por MySQL indisponível em `127.0.0.1:3307`.
- Próxima ação: documentar comando de teste via Docker e/ou criar script que sobe banco e prepara schema.

### Baixa: pequenos sinais de acabamento no código

- Evidência: `app/controllers/sessions_controller.rb`, `app/views/layouts/application.html.erb`.
- Impacto: baixo no comportamento, mas aumenta ruído de manutenção.
- Justificativa: há linha em branco desnecessária em `SessionsController#destroy` e ícones SVG inline extensos no layout.
- Próxima ação: agrupar limpeza visual em uma mudança menor, sem misturar com regras financeiras.

## Recomendações priorizadas

1. **Adicionar testes para regras financeiras principais**
   - Área: testes e domínio financeiro.
   - Ação: cobrir `Transaction`, `Category`, `CreditCardInvoiceSyncer`, `CreditCardInvoicePaymentService` e importador BB.
   - Benefício: reduz risco de saldo/fatura incorretos.
   - Prioridade: alta.

2. **Decidir estratégia de banco para produção**
   - Área: operação e dados.
   - Ação: validar PostgreSQL em CI ou alinhar produção com MariaDB.
   - Benefício: reduz risco de deploy quebrado por incompatibilidade de adapter/schema.
   - Prioridade: alta.

3. **Definir destino do domínio de investimentos**
   - Área: arquitetura e produto.
   - Ação: escolher entre remover, congelar ou reintroduzir investimentos com rotas e testes.
   - Benefício: reduz código órfão e confusão de escopo.
   - Prioridade: alta.

4. **Extrair cálculo de dashboard para serviço**
   - Área: refatoração.
   - Ação: criar objeto de consulta/serviço para métricas, gráficos, orçamento e faturas.
   - Benefício: elimina duplicação entre controllers e facilita testes.
   - Prioridade: média.

5. **Fortalecer frontend operacional**
   - Área: frontend e segurança.
   - Ação: vendorizar/pinar assets externos ou configurar CSP compatível com CDN.
   - Benefício: reduz dependência externa e melhora postura de segurança.
   - Prioridade: média.

6. **Criar caminho reprodutível de validação local**
   - Área: DX/CI.
   - Ação: documentar ou automatizar `docker compose up -d db`, `db:prepare` e `bin/rails test`.
   - Benefício: torna regressões mais fáceis de detectar.
   - Prioridade: média.

## Perguntas abertas e premissas

- O workspace atual contém muitas alterações não commitadas; a análise assume que o estado atual representa a direção pretendida.
- A produção deve oficialmente usar PostgreSQL no Render ou MariaDB em outro provedor?
- O domínio de investimentos ainda faz parte do produto desejado ou deve ser removido para reduzir complexidade?
- A análise inicial ficou limitada a inspeção estática e uma tentativa de testes; não houve verificação manual no navegador.
- Não foi validado se as dependências CDN estão aceitáveis para produção ou se devem ser vendorizadas.

## Follow-ups OpenSpec sugeridos

- `adicionar-testes-regras-financeiras`: cobrir parcelamento, faturas, orçamento e importação.
- `definir-banco-producao`: alinhar adapter, migrations, schema e pipeline de deploy.
- `resolver-dominio-investimentos`: decidir remoção/reintrodução dos modelos, serviços, rotas e views de investimento.
- `extrair-dashboard-service`: centralizar cálculos de dashboard e Turbo Streams.
- `fortalecer-assets-csp`: reduzir dependência de CDN e aplicar política CSP.
- `automatizar-validacao-local`: criar fluxo confiável para banco, migrations e testes.

## Validação executada

- `bin/rails test`: falhou antes da execução da suíte por indisponibilidade do MySQL em `127.0.0.1:3307`.
- `openspec status --change "analisar-projeto"`: executado antes da implementação e indicou artefatos completos.
