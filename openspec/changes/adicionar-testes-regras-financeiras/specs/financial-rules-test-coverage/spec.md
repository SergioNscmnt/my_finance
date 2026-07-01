## ADDED Requirements

### Requirement: Cobertura de regras de transação
O projeto DEVE testar regras de impacto mensal, parcelamento e início de cobrança de cartão.

#### Scenario: Parcela impacta meses corretos
- **WHEN** uma transação parcelada de cartão é avaliada por mês
- **THEN** apenas os meses dentro do intervalo de parcelas recebem valor mensal

### Requirement: Cobertura de cartão e faturas
O projeto DEVE testar cálculo de mês de cobrança, vencimento, sincronização e pagamento de faturas.

#### Scenario: Fatura é sincronizada
- **WHEN** existem transações de cartão em uma categoria de cartão
- **THEN** a fatura mensal reflete o total esperado e o vencimento calculado

### Requirement: Cobertura de importação de extrato
O projeto DEVE testar parsing e idempotência da importação Banco do Brasil.

#### Scenario: Linha parcelada é importada
- **WHEN** o importador recebe uma linha parcelada válida
- **THEN** cria transação com valor total, parcelas e data inicial esperados
