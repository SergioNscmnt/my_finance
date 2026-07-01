## Why

A validação local ainda depende de um banco MySQL/MariaDB previamente ativo e `bin/rails test` falhou ao tentar conectar em `127.0.0.1:3307`. Antes de ampliar a cobertura de testes, o projeto precisa de um fluxo reproduzível para preparar banco, rodar migrations e executar a suíte.

## What Changes

- Adicionar um caminho documentado e/ou automatizado para executar validação local com banco de teste.
- Garantir que o fluxo cubra subida do MariaDB, preparação do schema e execução de `bin/rails test`.
- Registrar pré-requisitos, variáveis de ambiente e comandos recomendados para execução local e via Docker.
- Preservar o comportamento da aplicação; esta mudança foca em DX, documentação e scripts de validação.

## Capabilities

### New Capabilities

- `local-validation`: Define como preparar e executar a validação local do projeto de forma reproduzível.

### Modified Capabilities

- Nenhuma.

## Impact

- Documentação afetada: README, docs ou scripts de apoio de desenvolvimento.
- Código afetado: possível adição de script/tarefa para validação local, sem alterar regras de negócio.
- Banco de dados: apenas preparação/uso do banco de teste local.
- APIs e UI: nenhuma mudança.
- Dependências: nenhuma prevista.
