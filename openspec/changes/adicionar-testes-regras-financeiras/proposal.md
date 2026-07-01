## Why

As regras financeiras principais ainda não têm cobertura efetiva, embora afetem saldos, parcelas, faturas, orçamento e importação de extrato. Sem testes automatizados, regressões em cálculos como impacto mensal, vencimento de fatura e parcelamento podem chegar ao produto sem sinal claro.

## What Changes

- Adicionar testes para regras de `Transaction`, `Category`, `CreditCardInvoiceSyncer`, `CreditCardInvoicePaymentService` e importação Banco do Brasil.
- Cobrir cenários de parcelamento, início de cobrança, vencimento, sincronização/pagamento de faturas e parsing/idempotência de importação.
- Usar fixtures ou dados de teste explícitos para casos financeiros representativos.
- Não alterar comportamento funcional nesta mudança, exceto correções mínimas caso testes revelem bug confirmado e escopo seja aprovado.

## Capabilities

### New Capabilities

- `financial-rules-test-coverage`: Define a cobertura mínima de testes para regras financeiras críticas.

### Modified Capabilities

- Nenhuma.

## Impact

- Testes afetados: Minitest models/services e fixtures relacionadas.
- Código afetado: preferencialmente nenhum; eventuais ajustes de testability devem ser mínimos.
- Banco de dados: uso do schema de teste existente.
- APIs e UI: nenhuma mudança.
- Dependências: nenhuma prevista.
