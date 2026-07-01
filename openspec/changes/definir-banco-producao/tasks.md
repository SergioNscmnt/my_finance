## 1. Decisão

- [ ] 1.1 Comparar manter PostgreSQL no Render versus alinhar produção com MariaDB.
- [ ] 1.2 Registrar decisão e critérios em documentação.

## 2. Ajustes

- [ ] 2.1 Ajustar `Gemfile` e `config/database.yml` conforme a estratégia escolhida.
- [ ] 2.2 Ajustar `bin/docker-entrypoint` para preparação coerente do banco.
- [ ] 2.3 Atualizar README/deploy com variáveis e comandos corretos.

## 3. Verificação

- [ ] 3.1 Validar migrations em banco limpo do adapter escolhido.
- [ ] 3.2 Confirmar que o fluxo local/teste continua funcionando.
