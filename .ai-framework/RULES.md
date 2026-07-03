# Regras Para IA

Este arquivo define as regras de trabalho para agentes de IA neste projeto.
Use-o como fonte de contexto antes de propor ou aplicar mudanças.

## Contexto Do Projeto

- Produto: aplicação de finanças pessoais para receitas, despesas, categorias, orçamento, cartão de crédito, carteira de investimentos e dados de mercado.
- Stack principal: Ruby 3.0.2, Rails 7.1.6, MariaDB 10.11 em desenvolvimento, PostgreSQL em produção via `DATABASE_URL`.
- Frontend: ERB, Turbo, Stimulus via importmap, TailwindCSS v4 com `tailwindcss-rails`.
- Autenticação: sessão própria com `current_user`; sempre escopar dados por usuário.
- Validação local preferida: `bin/validate-local`.

## Regras Gerais

- Antes de editar, leia os arquivos relacionados e siga o padrão existente.
- Faça mudanças pequenas, focadas e reversíveis. Evite refatorações fora do pedido.
- Preserve nomes de domínio já usados no app: `Transaction`, `Category`, `CategoryBudget`, `CreditCardInvoice`, `Wallet`, `Asset`, `Portfolio`, etc.
- Use português nos textos de UI, mensagens e labels, seguindo o tom atual da aplicação.
- Não introduza novas dependências sem necessidade clara.
- Não remova funcionalidades existentes para simplificar uma alteração.
- Não exponha secrets, tokens, chaves privadas ou credenciais reais. Credenciais de seed devem permanecer apenas demonstrativas.

## Rails E Ruby

- Prefira models/services/controllers Rails convencionais antes de criar abstrações novas.
- Regras de negócio financeiras devem ficar em models ou services, não espalhadas em views.
- Controllers devem orquestrar dados para a view; evite lógica pesada em ERB.
- Sempre escopar consultas por `current_user` quando o dado pertence ao usuário.
- Use enums existentes em vez de strings soltas quando houver enum no model.
- Preserve compatibilidade com Ruby 3.0.2.
- Evite APIs de Ruby/Rails mais novas que não estejam disponíveis nesta versão.
- Comentários devem ser poucos e úteis, explicando regras de negócio não óbvias.

## Banco De Dados E Migrations

- Desenvolvimento usa MariaDB via Docker Compose; produção pode usar PostgreSQL.
- Escreva migrations compatíveis com MySQL/MariaDB e PostgreSQL quando possível.
- Para bancos locais já populados, prefira migrations tolerantes a estado parcial quando isso evitar erro de coluna/índice já existente.
- Não edite `db/schema.rb` manualmente; deixe Rails regenerar quando necessário.
- Não apague volumes Docker ou dados locais sem pedido explícito do usuário.
- Em seeds, mantenha idempotência: usar `find_or_create_by!`, `find_or_initialize_by` ou padrão equivalente.

## Finanças E Cálculos

- Valores monetários devem usar `decimal` no banco e evitar `float` para persistência.
- Parcelas de cartão devem respeitar a lógica de `Transaction#monthly_amount_for`, `#billing_months`, `#billing_start_month` e `CreditCardInvoiceSyncer`.
- Ao alterar cálculo mensal, saldo acumulado, orçamento ou faturas, revise impacto em dashboard, gráficos, transações e testes de model.
- Despesas reduzem saldo; receitas aumentam saldo. Mantenha essa convenção explícita.

## Frontend, Layout E Design

- Padrão visual documentado em `.ai-framework/DESIGN.md`; seguir sempre ao criar ou alterar views.
- Use TailwindCSS no estilo já presente nas views.
- Preserve Turbo Frames e Turbo Streams existentes quando alterar telas interativas.
- Use Stimulus para comportamento client-side reaproveitável; evite JavaScript inline em ERB.
- Mantenha views responsivas e acessíveis: labels, botões claros, estados vazios e contraste adequado.
- Não introduza outro framework frontend.

## Docker E Ambiente

- Fluxo principal com Docker:
  - `docker compose build web`
  - `docker compose up -d db`
  - `docker compose run --rm web bin/rails db:create db:migrate db:seed`
  - `docker compose up -d web`
- A porta da aplicação é `3000`; MariaDB é exposto em `3307`.
- Se gems mudarem, rebuildar a imagem `web`.
- Orphans do Compose podem ser limpos com `docker compose up -d --remove-orphans`, sem remover volumes.

## Testes E Validação

- Para mudanças de backend, rode preferencialmente:
  ```bash
  bin/validate-local
  ```
- Para mudanças pequenas de view sem regra de negócio, no mínimo valide que a aplicação sobe e que a tela afetada renderiza.
- Ao mexer em models/services financeiros, adicione ou atualize testes em `test/models` ou `test/services` quando aplicável.
- Se não for possível rodar testes, registre claramente o motivo e o risco residual.

## Guard Rails

- Não executar comandos destrutivos como `git reset --hard`, `git checkout --`, remoção de volumes ou limpeza de banco sem autorização explícita.
- Não reverter alterações do usuário.
- Não commitar automaticamente sem pedido.
- Não alterar credenciais, chaves, secrets ou arquivos criptografados sem pedido.
- Não adicionar dados reais no seed, fixtures, README ou exemplos.
- Não fazer grandes reescritas de layout ou arquitetura quando o pedido for pontual.
- Não trocar MariaDB, Tailwind, Turbo/Stimulus ou importmap por outra tecnologia sem uma proposta aprovada.
