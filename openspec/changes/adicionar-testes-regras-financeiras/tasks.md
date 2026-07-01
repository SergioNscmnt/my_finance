## 1. Preparação

- [ ] 1.1 Garantir que a suíte Minitest roda com banco de teste preparado.
- [ ] 1.2 Revisar fixtures existentes e decidir entre fixtures ou factories manuais nos testes.

## 2. Testes de domínio

- [ ] 2.1 Adicionar testes para `Transaction#monthly_amount_for`, `#monthly_impact` e `#installment_number_for`.
- [ ] 2.2 Adicionar testes para `Category#billing_month_for` e `#due_date_for_billing_month`.
- [ ] 2.3 Adicionar testes para `CreditCardInvoiceSyncer` e `CreditCardInvoicePaymentService`.
- [ ] 2.4 Adicionar testes para parsing/idempotência do importador Banco do Brasil.

## 3. Verificação

- [ ] 3.1 Rodar `bin/rails test`.
- [ ] 3.2 Registrar bugs encontrados fora do escopo como follow-up.
