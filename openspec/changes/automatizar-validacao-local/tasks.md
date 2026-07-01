## 1. Diagnóstico

- [x] 1.1 Confirmar variáveis e portas usadas por `config/database.yml` e `docker-compose.yml`.
- [x] 1.2 Reproduzir ou documentar a falha atual de `bin/rails test` sem banco ativo.

## 2. Implementação

- [x] 2.1 Adicionar documentação ou script para subir banco de teste e preparar schema.
- [x] 2.2 Adicionar comando único recomendado para executar a suíte local.
- [x] 2.3 Incluir alternativa para execução sem Docker quando aplicável.

## 3. Verificação

- [ ] 3.1 Executar o fluxo documentado até a etapa de teste.
- [x] 3.2 Confirmar que falhas de banco têm instruções claras de correção.

Observação: `bin/validate-local` foi executado neste ambiente, mas parou antes da etapa de teste porque o Docker Desktop não está integrado à distro WSL.
