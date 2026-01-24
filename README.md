# MyFinance

Plataforma web (Rails 7 + TailwindCSS v4 + Turbo/Stimulus) para controle financeiro pessoal: cadastre receitas, despesas, metas e acompanhe saldo mensal com UI responsiva e acessível.

## Stack
- Ruby 3.0.2 · Rails 7.1.6
- MariaDB 10.11 (via Docker)
- TailwindCSS v4 (gem `tailwindcss-rails`)
- Turbo/Stimulus (importmap) + Select2 (via CDN)

## Requisitos
- Docker e Docker Compose instalados
- Porta 3000 livre para a aplicação e 3307 (mapeia 3306 do MariaDB) para o banco

## Configuração rápida (Docker)
```bash
# 1) Instalar dependências Ruby e front dentro da imagem
docker compose build --no-cache web

# 2) Subir banco
docker compose up -d db

# 3) Criar banco e rodar seeds (cria usuário demo e categorias padrão por usuário)
docker compose run --rm web bin/rails db:create db:migrate db:seed

# 4) Precompilar assets (Tailwind v4, importmap)
docker compose run --rm web bin/rails tailwindcss:build
docker compose run --rm web bin/rails assets:precompile

# 5) Subir aplicação
docker compose up -d web
```

Acesse http://localhost:3000

Credenciais seed (podem ser alteradas via env `SEED_USER_EMAIL`/`SEED_USER_PASSWORD`):
- Email: `demo@example.com`
- Senha: `password123`

## Uso básico
- Botões “Nova receita” e “Nova despesa” já definem o tipo e abrem o formulário.
- Categorias são criadas por usuário (callback no `User`). Para popular usuários existentes:
  ```bash
  docker compose run --rm web bin/rails bootstrap:categories
  ```
- Dropdowns usam Select2 com busca e badges de tipo; grupos de categorias são filtrados pelo tipo da transação.

## Desenvolvimento local (sem Docker)
1. Instale Ruby 3.0.2 e bundler 2.5.11.
2. Instale MariaDB e crie um usuário/DB conforme `config/database.yml` (default: user `app`, senha `password`, DB `my_finance_development`).
3. `bundle install`
4. `bin/rails db:create db:migrate db:seed`
5. `bin/rails tailwindcss:build`
6. `bin/rails server`

## Scripts úteis
- Rodar seeds + categorias para todos usuários: `bin/rails bootstrap:categories`
- Limpar e reconstruir assets: `bin/rails assets:clobber && bin/rails tailwindcss:build && bin/rails assets:precompile`

## Notas de UI/UX
- Paleta semântica: verde (confirmar), vermelho (perigo), azul (informativo), âmbar (alerta).
- Formulário de transação mostra badge de tipo e filtra categorias por receita/despesa.
- Select2 estilizado para harmonizar com Tailwind (borda única, foco suave).

## Testes
(Nenhum test suite configurado ainda. Sugestão: adicionar RSpec ou Minitest com system tests para fluxos de transação.)

## Suporte
Issues e PRs são bem-vindos. Ajuste variáveis no `docker-compose.yml`/`.env.example` conforme seu ambiente.***
