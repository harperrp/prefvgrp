# RADGOV — Portal público e painel administrativo

Sistema PHP/MySQL pronto para hospedagem comum com cPanel/FTP. O portal público lê dados reais via API e o painel administrativo grava no banco automaticamente.

## Requisitos

- PHP 8.1 ou superior.
- MySQL 5.7+ ou MariaDB 10.4+.
- Extensões PHP: PDO, pdo_mysql, fileinfo, json, mbstring, session.
- Apache com `.htaccess` habilitado para URLs `/api/...`.

## Estrutura principal

- `index.html`: portal público.
- `painel-adm.html`: painel administrativo protegido por sessão.
- `admin/login.html`: login do administrador.
- `api/index.php`: API pública e administrativa.
- `api/config/config.example.php`: modelo de configuração.
- `api/config/config.php`: arquivo onde você preenche os dados reais.
- `database/schema.sql`: estrutura das tabelas.
- `database/seed.sql`: dados iniciais.
- `database/install.sql`: estrutura + dados iniciais para importar no phpMyAdmin.
- `uploads/`: imagens e documentos enviados pelo painel.

## Configuração do banco

1. Crie o banco MySQL, usuário e senha no cPanel.
2. Importe `database/install.sql` pelo phpMyAdmin.
3. Copie `api/config/config.example.php` para `api/config/config.php` se ainda não existir.
4. Edite `api/config/config.php` e preencha:

```php
'db_host' => 'DB_HOST_AQUI',
'db_name' => 'DB_NAME_AQUI',
'db_user' => 'DB_USER_AQUI',
'db_pass' => 'DB_PASS_AQUI',
'base_url' => 'https://SEU-SUBDOMINIO.com.br',
'upload_url' => 'https://SEU-SUBDOMINIO.com.br/uploads/',
```

Não deixe credenciais reais em repositórios públicos.

## Login inicial do painel

- URL: `https://SEU-SUBDOMINIO.com.br/admin/login.html`
- E-mail: `admin@radgov.com.br`
- Senha inicial: `Admin@12345`

Troque a senha no primeiro acesso pelo módulo **Usuários** editando o usuário administrador e preenchendo o campo de senha.

## Como publicar uma notícia

1. Acesse o painel.
2. Abra o módulo **Notícias**.
3. Clique em **Novo registro**.
4. Preencha título, categoria, resumo e conteúdo.
5. Faça upload de imagem destacada, se desejar.
6. Defina `status` como `published`.
7. Salve.
8. Abra o portal público e confira a notícia em **Últimas notícias**.

## Segurança implementada

- PDO com prepared statements.
- Senhas com `password_hash` e validação com `password_verify`.
- Sessões PHP com cookie `HttpOnly` e `SameSite=Lax`.
- CSRF token nas rotas administrativas que alteram dados.
- Upload com whitelist de extensões e bloqueio de scripts por `.htaccess`.
- Soft delete por `deleted_at`.
- Conteúdo público só aparece quando publicado/ativo.
- Auditoria de login, criação, edição, exclusão, upload e resposta de ouvidoria.
- Versionamento de conteúdo editado/criado.

## Checklist rápido

1. Portal abre em `/index.html`.
2. `/api/public/settings` responde JSON.
3. Login em `/admin/login.html` funciona.
4. Acessar `/painel-adm.html` sem login redireciona para login.
5. Criar notícia com `published` aparece no portal.
6. Criar notícia com `draft` não aparece no portal.
7. Upload de imagem e PDF salva em `uploads/` e registra em `files`.
8. Ouvidoria gera protocolo e permite resposta pelo painel.
9. Configurações salvam e aparecem no portal.
10. Auditoria e versionamento recebem registros.

## Hospedagem com raiz diferente

Se sua hospedagem não usar `public_html` como raiz, envie o conteúdo da pasta `public_html` para a raiz configurada do subdomínio. Mantenha a estrutura interna igual: `api/`, `assets/`, `admin/`, `database/`, `docs/` e `uploads/`.
