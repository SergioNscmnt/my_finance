# Roadmap de melhorias do MyFinance

Data do roadmap: 2026-06-03  
Fonte principal: `openspec/changes/analisar-projeto/analysis-report.md`  
Escopo: documentação de priorização; não altera código, schema, rotas, dependências ou UI.

## Critérios de priorização

- **Impacto:** tamanho do benefício para corretude financeira, estabilidade, segurança, operação ou evolução do produto.
- **Esforço:** estimativa relativa para entregar uma mudança revisável.
- **Risco reduzido:** gravidade do risco mitigado pela melhoria.
- **Dependências:** decisões ou mudanças que precisam acontecer antes.
- **Urgência:** necessidade de resolver antes de novas funcionalidades maiores.

## Roadmap priorizado

| Prioridade | Área | Melhoria | Impacto | Esforço | Risco reduzido | Dependências | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Testes | Adicionar testes para regras financeiras principais | Alto | Médio | Alto | Banco de teste executável | Pronta com dependência operacional |
| P0 | Dados/Operação | Definir estratégia oficial de banco em produção | Alto | Médio | Alto | Decisão de produto/infra | Requer decisão |
| P0 | Arquitetura/Produto | Resolver destino do domínio de investimentos | Alto | Médio/Alto | Alto | Decisão de produto | Requer decisão |
| P1 | Refatoração | Extrair cálculo de dashboard para serviço | Médio/Alto | Médio | Médio | Testes financeiros básicos | Pronta após P0 de testes |
| P1 | DX/CI | Automatizar validação local com banco e testes | Médio | Baixo/Médio | Médio | Escolha do fluxo Docker/local | Pronta |
| P1 | Segurança/Frontend | Fortalecer assets externos e CSP | Médio | Médio | Médio | Decidir CDN vs vendorização | Requer decisão leve |
| P2 | Importação | Robustecer importação de PDF Banco do Brasil | Médio | Médio | Médio | Fixtures e casos reais de extrato | Pronta após testes base |
| P2 | Segurança | Formalizar padrão de autorização por usuário | Médio | Médio | Médio | Inventário de controllers atuais | Pronta |
| P3 | Manutenção | Limpeza de acabamento e componentes visuais | Baixo | Baixo | Baixo | Nenhuma | Backlog |

## Melhorias prontas para OpenSpec

### 1. `automatizar-validacao-local`

- **Objetivo:** criar um caminho reprodutível para preparar banco, rodar migrations e executar `bin/rails test`.
- **Evidência:** `bin/rails test` falhou por MySQL indisponível em `127.0.0.1:3307`; `docker-compose.yml` define banco MariaDB e porta 3307; `config/database.yml` depende de variáveis de ambiente.
- **Escopo inicial:** documentar/compor comando de teste via Docker, preparar banco de teste e registrar pré-requisitos.
- **Benefício esperado:** aumenta confiança local e reduz atrito antes de adicionar testes reais.
- **Prioridade sugerida:** P1, mas pode ser executada antes dos testes P0 para destravar validação.

### 2. `adicionar-testes-regras-financeiras`

- **Objetivo:** cobrir as regras que afetam saldo, parcelamento, faturas e importação.
- **Evidência:** `app/models/transaction.rb`, `app/models/category.rb`, `app/services/credit_card_invoice_syncer.rb`, `app/services/credit_card_invoice_payment_service.rb`, `app/services/statement_imports/banco_do_brasil_pdf_importer.rb`, `test/models/transaction_test.rb`.
- **Escopo inicial:** testes unitários para `Transaction#monthly_amount_for`, `Transaction#billing_start_month`, `Category#billing_month_for`, `Category#due_date_for_billing_month`, sincronização/pagamento de faturas e parsing de importação.
- **Benefício esperado:** reduz risco de regressão em cálculos financeiros.
- **Prioridade sugerida:** P0.

### 3. `definir-banco-producao`

- **Objetivo:** decidir e validar o banco oficial de produção.
- **Evidência:** `Gemfile` usa `mysql2` e `pg`; `config/database.yml` usa MySQL por padrão e `DATABASE_URL` em produção; `bin/docker-entrypoint` evita `db:prepare` porque `schema.rb` MySQL pode quebrar no PostgreSQL.
- **Escopo inicial:** escolher PostgreSQL ou MariaDB para produção, ajustar documentação, entrypoint e validação de migrations conforme a decisão.
- **Benefício esperado:** reduz risco de deploy quebrado e divergência entre ambientes.
- **Prioridade sugerida:** P0.

### 4. `resolver-dominio-investimentos`

- **Objetivo:** decidir se o domínio de investimentos será removido, congelado ou reintroduzido.
- **Evidência:** `db/schema.rb` e `app/models/*` mantêm tabelas/modelos de investimentos; `config/routes.rb` não expõe rotas de investimento; `git status --short` mostra remoções de controllers/views/serviços relacionados.
- **Escopo inicial:** inventariar código/tabelas de investimento, decidir caminho, documentar migração ou reintrodução.
- **Benefício esperado:** reduz código órfão e clareia a direção do produto.
- **Prioridade sugerida:** P0.

### 5. `extrair-dashboard-service`

- **Objetivo:** centralizar cálculos de dashboard usados por página e Turbo Streams.
- **Evidência:** `DashboardController`, `TransactionsController#dashboard_data` e `CategoryBudgetsController#load_budget_planner_data` replicam cálculos de saldo, orçamento, gráficos e faturas.
- **Escopo inicial:** criar serviço/query object para métricas do dashboard e adaptar controllers sem alterar comportamento esperado.
- **Benefício esperado:** reduz duplicação e facilita testes.
- **Prioridade sugerida:** P1, após testes financeiros básicos.

### 6. `fortalecer-assets-csp`

- **Objetivo:** reduzir dependência operacional de CDN e aplicar política de segurança consistente.
- **Evidência:** `app/views/layouts/application.html.erb` carrega Chart.js, Tom Select e Flatpickr por CDN; `config/initializers/content_security_policy.rb` está comentado.
- **Escopo inicial:** escolher entre vendorização/pinning local ou CSP com domínios permitidos; validar charts, selects e datepicker.
- **Benefício esperado:** melhora resiliência de frontend e postura de segurança.
- **Prioridade sugerida:** P1.

## Itens que exigem decisão antes de implementação

- **Banco de produção:** escolher PostgreSQL no Render com CI equivalente ou alinhar produção com MariaDB.
- **Domínio de investimentos:** decidir se a estratégia é remoção, congelamento documentado ou reintrodução funcional.
- **Assets externos:** decidir se dependências JS/CSS continuam via CDN ou entram no pipeline local.
- **Escopo de validação visual:** decidir se próximos roadmaps incluem verificação manual/screenshot ou apenas testes automatizados.

## Backlog controlado

- **Padrão de autorização por usuário:** documentar e testar o uso obrigatório de `current_user.*` em controllers sensíveis.
- **Importação de PDF com fixtures reais:** adicionar exemplos estáveis de extratos ou texto extraído para reduzir fragilidade do parser.
- **Limpeza visual e manutenção:** reduzir SVG inline extenso no layout e pequenos ruídos como espaços em branco, em mudança separada.
- **Observabilidade leve:** considerar logs estruturados para importação e sincronização de faturas depois que testes existirem.

## Sequência recomendada

1. `automatizar-validacao-local`
2. `adicionar-testes-regras-financeiras`
3. `definir-banco-producao`
4. `resolver-dominio-investimentos`
5. `extrair-dashboard-service`
6. `fortalecer-assets-csp`

Essa sequência privilegia confiança e decisões estruturais antes de refatorações maiores.

## Verificação dos requisitos

- Cada recomendação acima possui evidência ou está marcada como decisão pendente.
- Cada melhoria possui área, impacto, esforço, risco reduzido, dependências e prioridade.
- Mudanças que dependem de decisão de produto/infra foram separadas das prontas para implementação.
- O roadmap é documental e não altera comportamento em runtime.
