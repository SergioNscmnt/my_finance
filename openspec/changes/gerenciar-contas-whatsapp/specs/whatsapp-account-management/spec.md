## ADDED Requirements

### Requirement: Cadastro de vínculo WhatsApp
O sistema DEVE permitir que um usuário autenticado cadastre um vínculo de WhatsApp com telefone e instância Evolution.

#### Scenario: Usuário cadastra telefone válido
- **WHEN** o usuário informa telefone e instância na página de conta
- **THEN** o sistema cria um `WhatsappAccount` associado ao usuário atual

#### Scenario: Telefone é normalizado
- **WHEN** o usuário cadastra um telefone com símbolos, espaços ou prefixos
- **THEN** o sistema persiste o telefone normalizado apenas com dígitos

### Requirement: Listagem de vínculos do usuário
O sistema DEVE exibir ao usuário autenticado apenas seus próprios vínculos WhatsApp.

#### Scenario: Página de conta exibe vínculos próprios
- **WHEN** o usuário acessa a página de conta
- **THEN** o sistema lista telefone, instância, status e último uso dos vínculos pertencentes a esse usuário

#### Scenario: Vínculos de outro usuário não aparecem
- **WHEN** outro usuário possui um vínculo WhatsApp cadastrado
- **THEN** esse vínculo não aparece na página de conta do usuário atual

### Requirement: Alteração de status do vínculo
O sistema DEVE permitir ativar ou desativar um vínculo WhatsApp do próprio usuário.

#### Scenario: Usuário desativa vínculo
- **WHEN** o usuário desativa um vínculo ativo
- **THEN** o sistema marca o vínculo como inativo e o bot deixa de aceitar mensagens desse vínculo

#### Scenario: Usuário ativa vínculo
- **WHEN** o usuário ativa um vínculo inativo
- **THEN** o sistema marca o vínculo como ativo para uso pelo bot

### Requirement: Remoção de vínculo
O sistema DEVE permitir que o usuário remova um vínculo WhatsApp sem apagar transações ou eventos históricos já registrados.

#### Scenario: Usuário remove vínculo
- **WHEN** o usuário remove um vínculo WhatsApp
- **THEN** o sistema apaga o vínculo e preserva eventos/transações já existentes

### Requirement: Segurança por escopo de usuário
O sistema DEVE impedir que um usuário altere, teste ou remova vínculos pertencentes a outro usuário.

#### Scenario: Usuário tenta alterar vínculo alheio
- **WHEN** o usuário envia uma requisição para alterar um vínculo de outro usuário
- **THEN** o sistema não altera o vínculo e retorna resposta de não encontrado ou não autorizado

### Requirement: Mensagem de teste
O sistema DEVE permitir enviar uma mensagem de teste para um vínculo WhatsApp cadastrado usando a Evolution API.

#### Scenario: Teste enviado com configuração válida
- **WHEN** o usuário solicita teste para um vínculo próprio e a Evolution API está configurada
- **THEN** o sistema envia uma mensagem pelo WhatsApp e informa sucesso ao usuário

#### Scenario: Teste falha por configuração ausente
- **WHEN** o usuário solicita teste sem `EVOLUTION_API_BASE_URL`, `EVOLUTION_API_KEY` ou instância válida
- **THEN** o sistema informa erro controlado sem remover ou alterar o vínculo

### Requirement: Documentação operacional
O projeto DEVE documentar como configurar o webhook e as variáveis necessárias para usar os vínculos WhatsApp.

#### Scenario: Desenvolvedor consulta configuração
- **WHEN** um desenvolvedor lê a documentação do projeto
- **THEN** encontra as variáveis da Evolution API, o endpoint de webhook e o evento `MESSAGES_UPSERT` exigido
