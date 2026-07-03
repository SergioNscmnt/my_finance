# Design System

Guia visual do MyFinance para criação e alteração de telas. Use TailwindCSS e os padrões já existentes antes de criar classes novas.

## Princípios

- Interface de produto financeiro: clara, densa, objetiva e fácil de escanear.
- Priorize leitura de números, comparação de valores, status e ações rápidas.
- Evite estética de landing page, banners grandes, ilustrações decorativas e excesso de gradientes.
- Toda tela deve funcionar bem em mobile e desktop.
- Sempre manter suporte a dark mode com variante `dark:`.

## Paleta

### Base

- Fundo da aplicação:
  - Light: `bg-gray-50` ou `bg-slate-50`
  - Dark: `dark:bg-slate-950`
- Superfícies principais:
  - Light: `bg-white`
  - Dark: `dark:bg-slate-900`
- Superfícies secundárias:
  - Light: `bg-slate-50`
  - Dark: `dark:bg-slate-800/50` ou `dark:bg-slate-800/20`
- Bordas:
  - Light: `border-slate-200`, campos `border-slate-300`
  - Dark: `dark:border-slate-700`, campos `dark:border-slate-600`
- Texto principal:
  - Light: `text-slate-900`
  - Dark: `dark:text-slate-100`
- Texto secundário:
  - Light: `text-slate-500` ou `text-slate-600`
  - Dark: `dark:text-slate-400` ou `dark:text-slate-300`

### Cores Semânticas

- Receita, saldo positivo, sucesso:
  - `emerald`
  - Botão primário: `bg-emerald-600 hover:bg-emerald-700 text-white`
  - Texto positivo: `text-emerald-700 dark:text-emerald-400`
  - Badge: `bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300`
- Despesa, saída, atenção moderada:
  - `amber`
  - Texto de despesa: `text-amber-700 dark:text-amber-400`
  - Badge: `bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-200`
- Informações, filtros, metas, bancos:
  - `blue` ou `sky`
  - Botão secundário forte: `bg-blue-600 hover:bg-blue-700 text-white`
  - Foco em campos: `focus:border-blue-500 dark:focus:border-sky-400`
- Erro, perigo, saldo negativo:
  - `red` ou `rose`
  - Texto negativo: `text-red-600 dark:text-red-400`
  - Ação destrutiva: `border-red-200 text-red-600 hover:bg-red-50 dark:border-red-900/70 dark:text-red-300 dark:hover:bg-red-900/20`

### Gráficos

Use as cores atuais do Chart.js:

- Receitas: `#10b981`
- Despesas: `#f59e0b`
- Saldo acumulado: `#2563eb`
- Orçamento/categorias: `#0ea5e9`, `#22c55e`, `#f59e0b`, `#ef4444`, `#a855f7`, `#14b8a6`, `#f97316`, `#84cc16`

## Tipografia

- Usar a fonte padrão do Tailwind/sistema; não adicionar fonte externa sem aprovação.
- Labels e textos auxiliares: `text-xs` ou `text-sm`.
- Títulos de cards: `text-sm font-semibold`.
- Títulos de modal/formulário: `text-lg font-semibold`.
- Métricas principais em cards: `text-2xl font-semibold`.
- Saldo principal do dashboard: `text-3xl font-semibold`.
- Valores monetários devem usar `tabular-nums` quando estiverem em listas, cards compactos ou comparações.

## Layout

- Wrapper padrão de conteúdo: `w-full px-4 py-6 sm:px-6 lg:px-8`.
- Espaçamento vertical entre blocos: `space-y-6`.
- Grids responsivos:
  - Métricas: `grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-4`
  - Gráficos: `grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
  - Blocos largos: `grid grid-cols-1 gap-4 lg:grid-cols-12`
- Sidebar desktop:
  - Largura `w-72`
  - Fundo `bg-white dark:bg-slate-900`
  - Borda `border-r border-slate-200 dark:border-slate-800`
- Header mobile:
  - Sticky top, `bg-white/95 dark:bg-slate-900/95`, `backdrop-blur`.

## Cards E Painéis

- Card padrão:
  ```html
  rounded-xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-900
  ```
- Card de formulário/modal pode usar:
  ```html
  rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-700 dark:bg-slate-900
  ```
- Subcards compactos:
  ```html
  rounded-md border border-slate-200 bg-slate-50 px-3 py-2 dark:border-slate-700 dark:bg-slate-800/50
  ```
- List items internos:
  ```html
  rounded-lg border border-slate-200 bg-slate-50/40 px-3 py-3 dark:border-slate-700 dark:bg-slate-800/20
  ```
- Evite cards aninhados desnecessários. Use subcards apenas para itens repetidos ou métricas compactas.

## Botões

### Primário

Use para ação principal positiva:

```html
inline-flex items-center justify-center rounded-md bg-emerald-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-emerald-700 focus:outline focus:outline-2 focus:outline-emerald-400
```

### Secundário Neutro

Use para cancelar, voltar, filtros e ações menos importantes:

```html
inline-flex items-center justify-center rounded-md bg-slate-100 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-200 focus:outline focus:outline-2 focus:outline-slate-400 dark:bg-slate-800 dark:text-slate-200 dark:hover:bg-slate-700
```

### Secundário Azul

Use para importação, informação ou ação auxiliar forte:

```html
inline-flex items-center justify-center rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-blue-700 focus:outline focus:outline-2 focus:outline-blue-400
```

### Destrutivo

Use para remover, sair ou cancelar com perda:

```html
rounded-md border border-red-200 px-3 py-1.5 text-xs font-medium text-red-600 hover:bg-red-50 dark:border-red-900/70 dark:text-red-300 dark:hover:bg-red-900/20
```

### Regras De Botões

- Em mobile, ações principais podem ocupar `w-full`; em desktop, `sm:w-auto`.
- Use `inline-flex`, `items-center`, `justify-center` e `gap-2`.
- Sempre incluir estados `hover` e `focus`.
- Para botões compactos em listas, usar `text-xs`, `px-3`, `py-1` ou `py-1.5`.

## Formulários

Campos globais já são padronizados em `app/assets/stylesheets/application.css`.

- Altura padrão: `3rem`.
- Radius de campos: `0.75rem`.
- Borda light: `#cbd5e1` (`slate-300`).
- Borda dark: `#334155` (`slate-700`).
- Foco light: `#60a5fa` / halo `#bfdbfe`.
- Foco dark: `#38bdf8` com halo translúcido.

Classes comuns em campos:

```html
w-full rounded-lg border border-slate-300 px-4 py-3 text-sm shadow-sm focus:border-blue-500 focus:outline-none dark:border-slate-600 dark:bg-slate-900 dark:text-slate-100 dark:focus:border-sky-400
```

Labels:

```html
text-sm font-medium text-slate-700 dark:text-slate-200
```

Mensagens auxiliares:

```html
text-xs text-slate-500 dark:text-slate-400
```

Erros:

```html
text-xs text-red-600
```

## Badges E Status

- Badge base:
  ```html
  inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold
  ```
- Use `rounded-full` para status e labels curtos.
- Receitas: emerald.
- Despesas: amber.
- Bancos/metas: blue.
- Atrasado/acima do limite: red.
- Neutro/projetado: slate.

Badges existentes em CSS:

- `.badge-income`
- `.badge-expense`
- `.badge-bank`

## Estados Vazios E Alertas

Use o partial `shared/empty_alert` em vez de recriar estados vazios.

Tons disponíveis:

- `:info` usa sky.
- `:warning` usa amber.
- `:danger` usa red.
- `:success` usa emerald.

Para espaços pequenos, passar `compact: true`.

## Toasts

- Toasts ficam fixos no canto superior direito.
- Sucesso usa emerald.
- Alerta usa rose.
- Mantêm barra de progresso visual.
- Não criar outro padrão de flash sem necessidade.

## Modais

- Modal usa backdrop `bg-slate-900/60 backdrop-blur-sm`.
- Painel padrão:
  ```html
  max-w-3xl rounded-2xl bg-white shadow-2xl border border-slate-200 dark:bg-slate-900 dark:border-slate-700
  ```
- Conteúdo deve ser carregado em `turbo-frame id="modal"` quando seguir o padrão existente.

## Navegação

- Links da sidebar:
  ```html
  inline-flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 transition hover:bg-slate-100 hover:text-emerald-700 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-emerald-400
  ```
- A navegação deve ser simples, sem menus profundos.
- Ícones devem ter tamanho aproximado `h-5 w-5`.

## Dark Mode

- Dark mode é ativado por classe `.dark` no `html`/`body`.
- Toda nova superfície precisa ter classes `dark:`.
- Evite fundos claros sem par dark.
- Para overlays no dark, prefira `dark:bg-slate-900`, `dark:bg-slate-800/50`, `dark:bg-slate-950`.
- Texto em dark deve manter contraste: `dark:text-slate-100`, `dark:text-slate-200`, `dark:text-slate-300`, `dark:text-slate-400`.

## Responsividade

- Mobile primeiro.
- Use `flex-col` por padrão e `sm:flex-row` ou `md:flex-row` quando houver espaço.
- Grids devem começar com `grid-cols-1`.
- Ações lado a lado em desktop devem virar coluna ou `w-full` no mobile.
- Textos longos em cards/listas devem usar `min-w-0`, `break-words` ou wrapping adequado.

## Guard Rails Visuais

- Não criar paleta nova sem necessidade.
- Não usar gradientes decorativos, blobs, orbs ou ilustrações genéricas.
- Não usar cards gigantes para conteúdo simples.
- Não substituir Tailwind por CSS customizado se classes utilitárias bastarem.
- Não quebrar dark mode.
- Não remover estados vazios, feedback de erro ou confirmação de ações destrutivas.
- Não usar texto pequeno demais para valores financeiros importantes.
- Não usar cores sem significado semântico em métricas financeiras.
