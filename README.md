# MyFinance

Aplicação Rails para controle financeiro pessoal (receitas, despesas, categorias, metas) usando MariaDB e TailwindCSS v4.

## Stack resumida
- Ruby 3.0.2 · Rails 7.1.6
- MariaDB 10.11 (Docker)
- TailwindCSS v4 (gem `tailwindcss-rails`)
- Turbo/Stimulus via importmap

## Requisitos
- Docker + Docker Compose
- Portas: 3000 (app) e 3307 (mapeia 3306 do MariaDB)

## Subir com Docker (passos mínimos)
```bash
# Build da imagem
docker compose build web

# Subir banco
docker compose up -d db

# Criar banco, migrar e seed (cria usuário demo e categorias)
docker compose run --rm web bin/rails db:create db:migrate db:seed

# Build de assets (Tailwind) e pré-compilação
docker compose run --rm web bin/rails tailwindcss:build
docker compose run --rm web bin/rails assets:precompile

# Subir aplicação
docker compose up -d web
```
App em: http://localhost:3000

Credenciais seed (alteráveis via `SEED_USER_EMAIL`/`SEED_USER_PASSWORD`):
- Email: `demo@example.com`
- Senha: `password123`

## Desenvolvimento local (sem Docker)
1) Ruby 3.0.2 + bundler 2.5.11  
2) MariaDB configurado conforme `config/database.yml` (user `app`, senha `password`, DB `my_finance_development` por padrão)  
3) `bundle install`  
4) `bin/rails db:create db:migrate db:seed`  
5) `bin/rails tailwindcss:build`  
6) `bin/rails server`

## Tarefas úteis
- Repopular categorias padrão para todos os usuários existentes:
  ```bash
  docker compose run --rm web bin/rails bootstrap:categories
  ```
- Limpar e reconstruir assets:
  ```bash
  bin/rails assets:clobber && bin/rails tailwindcss:build && bin/rails assets:precompile
  ```

## Testes
Ainda não configurado (sugestão: adicionar RSpec ou Minitest + system tests).

## Suporte
Ajuste variáveis no `docker-compose.yml` ou `.env.example`. Issues/PRs são bem-vindos.

## Deploy no Render
Este projeto pode subir no Render usando `Docker` + banco `PostgreSQL` do próprio Render (em produção o app passa a ler `DATABASE_URL`).

1) Suba o código para GitHub/GitLab.
2) No Render, crie um banco `PostgreSQL` (ex.: `my-finance-db`).
3) Crie um `Web Service` a partir do repositório:
   - Runtime: `Docker`
   - Dockerfile Path: `./Dockerfile`
   - Health Check Path: `/up`
   - Start Command:
     ```bash
     ./bin/rails server -b 0.0.0.0 -p $PORT
     ```
4) Configure as variáveis de ambiente no Web Service:
   - `RAILS_ENV=production`
   - `RAILS_LOG_LEVEL=info`
   - `SECRET_KEY_BASE` (generate no Render)
   - `RAILS_MASTER_KEY` (valor do seu `config/master.key`)
   - `DATABASE_URL` (use o valor de conexão do banco PostgreSQL criado no Render)
5) Faça deploy. O `bin/docker-entrypoint` já executa `db:prepare` automaticamente na inicialização.

Observação: em desenvolvimento local, o projeto continua usando MariaDB via `docker-compose`.
