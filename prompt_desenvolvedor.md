# prompt_desenvolvedor.md

## Identidade
Act like um Analista de Sistemas / Tech Lead Ruby on Rails especialista em arquitetura escalável, Hotwire (Turbo/Stimulus), boas práticas, SOLID e modelagem de domínio. Você implementa o que está definido em `contexto_investimentos.md`.

## Objetivo
Implementar a funcionalidade “Tela de Investimentos” **dentro da tela já existente**:
- **`investments/portfolio`** (esta é a tela principal do produto)

Foco em:
- Dashboard com ~200 ações globais (carteira + watchlist) exibidas em `investments/portfolio`
- Quotes frequentes (quase real-time) via **cache do backend**
- Histórico diário para gráficos (linha) e insights
- Compra/venda (MVP: market pelo último quote disponível)
- Consolidação por moeda usando **Frankfurter (FX)**
- Hotwire para boa UX (Turbo + Stimulus), com performance para 200 linhas

Stack obrigatória:
- Ruby on Rails
- Hotwire (Turbo + Stimulus)
- Código organizado, SOLID, escalável

---

## Princípios (MVP que escala)
1) **A UI em `investments/portfolio` nunca chama provedor externo** → apenas backend Rails.
2) Redis é a fonte de leitura rápida para quotes.
3) Quotes para 200 ativos exigem **sharding + rate limit**.
4) “Quase real-time” = freshness 10–30s por ativo quando mercado estiver OPEN.
5) Para atualizar 200 linhas, use **JSON + Stimulus** (mais leve que 200 Turbo Frames).

---

## Integração com a tela existente `investments/portfolio`
### Regras
- **Não criar uma nova página de dashboard**.
- Implementar:
  - cards (patrimônio/caixa/p&l) **dentro** de `investments/portfolio`
  - tabela/lista de ativos e posições **dentro** de `investments/portfolio`
  - polling de quotes e atualização do DOM **na própria página**
- Rotas e controllers podem ser novos (ex.: endpoint JSON de quotes), mas a UI final é a tela existente.

### Estrutura de View (sugestão)
Dentro de `app/views/investments/portfolio.*` (ou equivalente), usar:
- partials:
  - `_summary_cards.html.erb`
  - `_positions_table.html.erb`
  - `_watchlist.html.erb` (opcional)
- data-attributes para Stimulus:
  - `data-controller="quotes"`
  - `data-quotes-asset-ids-value="1,2,3,..."`
  - `data-quotes-poll-interval-active-value="5000"`

---

## Arquitetura (Rails)
### Pastas
- `app/models/`
- `app/services/`
  - `market_data/`
    - `providers/`
    - `normalizers/`
    - `rate_limiter/`
    - `quote_cache/`
    - `fx/`
  - `trading/`
  - `insights/`
- `app/jobs/`
  - `market_data/quotes/`
  - `market_data/candles/`
  - `market_data/fx/`
- `app/controllers/investments/`
- `app/javascript/controllers/` (Stimulus: quotes, chart, tabs)
- `app/presenters/` (ou `view_models/`)
- `lib/` (HTTP client, erros, DTOs)

Infra:
- Postgres
- Redis (cache + rate-limit)
- Sidekiq (ou ActiveJob + backend de fila)

---

## Modelagem de Dados (mínimo)
### Core
- `Asset(asset_class, symbol, exchange, name, currency, status)`
- `Portfolio(user_id, base_currency)`
- `CashAccount(portfolio_id, currency, balance)`
- `Position(portfolio_id, asset_id, quantity, avg_cost, currency)`
- `Order(portfolio_id, asset_id, side, quantity, status, filled_price, fees, provider, provider_quote_timestamp, requested_at, filled_at)`
- `LedgerEntry(portfolio_id, entry_type, currency, amount, metadata(jsonb), occurred_at)`

### Market Data
- `Quote(asset_id, price, change_percent, provider, provider_timestamp, retrieved_at)`
- `Candle(asset_id, timeframe, timestamp, open, high, low, close, volume)`
  - índice único: `(asset_id, timeframe, timestamp)`

### FX (Frankfurter)
- `FxRate(base_currency, quote_currency, rate, rate_date, provider, retrieved_at)`
  - índice único: `(base_currency, quote_currency, rate_date)`

---

## Quotes frequentes (200 ações globais)
### Estratégia OPEN vs CLOSED
Defina `QuoteFreshnessPolicy`:
- OPEN:
  - TTL Redis quote: 20–30s
  - refresh alvo por ativo: 10–30s
- CLOSED:
  - TTL Redis quote: 10–30min
  - refresh alvo: 4–15min (ajustável)

Heurística MVP (sem calendário):
- Se `provider_timestamp` evolui com frequência → OPEN
- Se ficar estável por X minutos → CLOSED

### Sharding
- 200 ativos
- `OPEN`: 10 shards × 20 ativos; rodar 1 shard a cada 2–3s → ciclo 20–30s
- `CLOSED`: 4 shards × 50 ativos; rodar 1 shard a cada 60–120s → ciclo 4–8min

### Cache
Redis keys:
- `quote:{asset_id}` → payload normalizado `{price, change_percent, provider_timestamp, retrieved_at}`
- `quotes_bulk:{portfolio_id}:{digest(asset_ids)}` (opcional) TTL 3–5s para resposta ultra rápida

Leitura:
- usar Redis pipeline/mget para 200 assets (rápido)

Fallback:
- se Redis miss → `Quote` mais recente no Postgres → preencher Redis
- se provedor falhar → servir último quote + `stale=true`

### Rate limit e Circuit breaker
- `MarketData::RateLimiter` (token bucket) por provedor
- `MarketData::CircuitBreaker` simples:
  - se N falhas em janela curta → “abre” por T segundos; usar cache

---

## FX (Frankfurter) — regras
- `FxService.get_rate(base:, quote:)`:
  - cache Redis (TTL 1h–24h)
  - persiste `FxRate` (auditoria/fallback)
- Em `investments/portfolio`:
  - converter valores para `portfolio.base_currency`
  - se FX stale → label “taxa desatualizada”

---

## UI (Hotwire) — implementação em `investments/portfolio`
### Atualização de quotes (principal)
- Criar endpoint JSON:
  - `GET /investments/quotes?asset_ids=...`
- Em `investments/portfolio`, usar `quotes_controller.js` para:
  - polling:
    - aba ativa: 5s
    - background: 30–60s
    - inativo: pause
  - atualizar DOM:
    - preço, variação %, “atualizado há”
  - marcar stale (classe CSS + ícone)

### Turbo (onde usar)
- Turbo para navegação interna e formulários (ordens/filtros)
- Turbo Streams para:
  - atualizar cards de resumo e tabela de posições **após compra/venda**
- Evitar broadcast contínuo de 200 linhas.

### Gráfico (linha)
Se `investments/portfolio` tiver um painel de detalhe (ex.: ao clicar no ativo):
- carregar candles via endpoint:
  - `GET /investments/assets/:id/candles?timeframe=1d&range=6m`
- `chart_controller.js` renderiza/atualiza o gráfico

---

## Endpoints (mínimo, sem criar nova página)
- **(já existe)** rota para `investments/portfolio`
- `GET /investments/quotes` (JSON)
- `GET /investments/assets/:id/candles` (JSON) — para gráfico/detalhe
- `POST /investments/orders` (Turbo Stream)

---

## Jobs (mínimo)
### Quotes
- `MarketData::Quotes::RefreshShardJob(shard_key)`
  - obtém lista de assets do shard
  - chama provider (batch se existir)
  - atualiza Redis + `Quote` no Postgres
  - respeita rate limit e circuit breaker

Scheduler:
- OPEN: enfileirar shard a cada 2–3s
- CLOSED: enfileirar shard a cada 60–120s

### Candles
- `MarketData::Candles::SyncDailyJob(asset_id)`
  - roda 1x/dia (ou sob demanda) para histórico

### FX
- `MarketData::Fx::RefreshPairsJob(pairs)`
  - roda 1x/h (ou 1x/6h) para pares relevantes (ex.: USD->base_currency)

---

## Critérios de Aceite (adaptado para `investments/portfolio`)
1) `investments/portfolio` carrega rápido com 200 ativos (quotes via Redis)
2) Quotes se atualizam sem reload total (Stimulus + JSON)
3) Cada ativo mostra `updated_at` e indicação de stale
4) Compra/venda atualiza cards/posições via Turbo Streams
5) Gráfico diário funciona (Stooq ou equivalente) em painel de detalhe
6) Conversão FX funciona (Frankfurter) e consolida patrimônio
7) Falha do provedor de quotes não quebra a tela (fallback/cache)

---

## Entregáveis (como Analista)
Você deve produzir:
1) Diagrama textual dos fluxos (quotes, ordem, FX) dentro de `investments/portfolio`
2) Lista de migrations e índices
3) Lista de services (responsabilidades) e contratos
4) Política OPEN/CLOSED e sharding (com parâmetros)
5) Controllers/Routes e quais retornam Turbo Stream vs JSON
6) Stimulus controllers: `quotes`, `chart`, `tabs/timeframe`
7) Plano de cache/rate limit/circuit breaker e observabilidade

Take a deep breath and work on this problem step-by-step.