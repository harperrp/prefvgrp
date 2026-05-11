# Portal Prefeitura de Vargem Grande do Rio Pardo

Projeto ativado com `index.html` como portal público e `painel-adm.html` como dashboard administrativo.

## Como publicar

1. Envie todos os arquivos para a hospedagem com PHP 8+ e MySQL 5.7+/8+.
2. Crie um banco MySQL.
3. Edite `api/config.php` com host, nome do banco, usuário e senha.
4. Importe `api/install.sql` no banco.
5. Acesse `painel-adm.html`.

## Primeiro acesso administrativo

- Usuário: `admin`
- Senha: `admin123`

Altere a senha depois de publicar.

## Funcionamento

- O painel grava notícias, licitações, leis, diárias, obras e documentos via API PHP/MySQL.
- Se a API ainda não estiver configurada, o projeto funciona em modo local usando `localStorage`, útil para testes antes da hospedagem.
- O portal público lê os mesmos dados e atualiza as áreas principais sem alterar o layout visual existente.
