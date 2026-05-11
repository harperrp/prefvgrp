<?php
/**
 * Configuração MySQL do Portal Municipal.
 * Edite estes dados na hospedagem antes de importar api/install.sql.
 */
return [
    'db_host' => getenv('VG_DB_HOST') ?: 'localhost',
    'db_name' => getenv('VG_DB_NAME') ?: 'prefeitura_vgrp',
    'db_user' => getenv('VG_DB_USER') ?: 'db_user',
    'db_pass' => getenv('VG_DB_PASS') ?: 'db_senha',
    'db_charset' => 'utf8mb4',
    'session_name' => 'VG_PORTAL_ADMIN',
];
