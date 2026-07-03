## Why

A integração com Evolution API já depende de `WhatsappAccount` para resolver o número do WhatsApp para um usuário, mas hoje esse vínculo não tem fluxo de gerenciamento na aplicação. Sem uma tela para cadastrar, ativar, desativar e testar números, o bot fica operacionalmente frágil e dependente de console/seed.

## What Changes

- Adicionar interface autenticada para o usuário gerenciar seus números de WhatsApp vinculados.
- Permitir cadastrar telefone e instância Evolution, com normalização e validação de unicidade.
- Permitir ativar/desativar e remover vínculos sem afetar transações já criadas.
- Exibir status do vínculo, último uso e contadores/resumo básico de eventos recebidos.
- Adicionar ação para enviar mensagem de teste pelo cliente Evolution quando a API estiver configurada.
- Documentar o fluxo mínimo de configuração da Evolution API e do webhook.
- Não alterar o processamento do bot nem as regras de criação de transação.

## Capabilities

### New Capabilities

- `whatsapp-account-management`: Define como usuários autenticados cadastram, visualizam, testam, ativam/desativam e removem vínculos de WhatsApp usados pela integração Evolution API.

### Modified Capabilities

- Nenhuma.

## Impact

- Rotas/controladores: novo recurso autenticado para `WhatsappAccount` ou seção equivalente dentro de conta.
- Views: seção de WhatsApp na página de conta ou tela dedicada com formulário e lista de vínculos.
- Modelos: possíveis validações adicionais em `WhatsappAccount` para ergonomia de formulário.
- Serviços: reutilização de `Evolution::Client` para envio de mensagem de teste.
- Segurança: todos os vínculos devem ser escopados ao `current_user`; usuário não pode ver ou alterar conta WhatsApp de outro usuário.
- Documentação: atualização do README ou `.env-example` com instruções de configuração e teste.
