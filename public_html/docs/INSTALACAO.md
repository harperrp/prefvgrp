# Instalação em hospedagem comum cPanel/FTP

## Passo a passo

1. Compacte ou envie por FTP todo o conteúdo da pasta `public_html` deste projeto para a raiz do subdomínio.
2. No cPanel, crie um banco MySQL.
3. Crie um usuário do banco e vincule ao banco com todas as permissões.
4. Abra o phpMyAdmin.
5. Selecione o banco criado.
6. Importe o arquivo `database/install.sql`.
7. No FTP/Gerenciador de Arquivos, abra `api/config/`.
8. Duplique `config.example.php` e renomeie a cópia para `config.php` se necessário.
9. Edite `api/config/config.php` e preencha `db_host`, `db_name`, `db_user`, `db_pass`, `base_url` e `upload_url`.
10. Garanta que a pasta `uploads/` tenha permissão de escrita. Em hospedagem comum, use 755; se não funcionar, use 775 conforme orientação da hospedagem.
11. Acesse `https://SEU-SUBDOMINIO.com.br/admin/login.html`.
12. Entre com `admin@radgov.com.br` e senha `Admin@12345`.
13. Abra **Usuários**, edite o administrador e troque a senha.
14. Crie uma notícia de teste com status `published`.
15. Acesse `https://SEU-SUBDOMINIO.com.br/` e confirme se a notícia apareceu.

## Dados que devem ser preenchidos

No arquivo `api/config/config.php`:

```php
return [
    'db_host' => 'preencher_aqui',
    'db_name' => 'preencher_aqui',
    'db_user' => 'preencher_aqui',
    'db_pass' => 'preencher_aqui',
    'base_url' => 'https://meu-subdominio.com.br',
    'upload_dir' => __DIR__ . '/../../uploads/',
    'upload_url' => 'https://meu-subdominio.com.br/uploads/',
];
```

## Testes finais

- Portal público abre.
- API pública responde em `/api/public/news`.
- Login do painel funciona.
- Painel bloqueia usuário não logado.
- Notícias publicadas aparecem no portal.
- Rascunhos não aparecem no portal.
- Upload de imagem funciona.
- Upload de PDF funciona.
- Documentos, leis, licitações, obras e FAQ aparecem no portal quando publicados.
- Ouvidoria gera protocolo.
- Painel responde manifestação.
- Configurações salvam.
- Redirects salvam.
- Auditoria registra ações.
- Versionamento registra alterações.

## Problemas comuns

### A API retorna erro de instalação
Confira se `api/config/config.php` existe e se os dados do banco foram preenchidos.

### Upload não salva
Verifique permissão da pasta `uploads/` e se a extensão do arquivo é permitida.

### URLs `/api/...` dão 404
Confirme se o Apache permite `.htaccess`. Se a hospedagem bloquear rewrite, altere as chamadas do JavaScript para usar `/api/index.php/rota`.

### O subdomínio usa outra pasta raiz
Envie o conteúdo de `public_html` para a pasta raiz real do subdomínio, preservando as pastas internas.
