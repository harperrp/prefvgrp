<?php
/**
 * Configuração MySQL do Portal Municipal.
 * Edite estes dados na hospedagem antes de importar api/install.sql.
 */
return [
    'db_host' => getenv('VG_DB_HOST') ?: 'localhost',
    'db_name' => getenv('VG_DB_NAME') ?: 'banco2vgm',
    'db_user' => getenv('VG_DB_USER') ?: 'uservgm2',
    'db_pass' => getenv('VG_DB_PASS') ?: 'Vargemgrande@2026',
    'db_charset' => 'utf8mb4',
    'session_name' => 'VG_PORTAL_ADMIN',
];
