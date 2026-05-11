<?php
require __DIR__ . '/db.php';
$c = vg_config();
session_name($c['session_name']);
session_start();

$action = $_GET['action'] ?? 'state';
$body = vg_body();
$pdo = vg_pdo();

if (!$pdo) {
    vg_json(false, null, 'Configure o MySQL em api/config.php e importe api/install.sql.');
}

function row_to_item(array $row): array {
    $item = json_decode($row['data_json'], true) ?: [];
    $item['id'] = $row['id'];
    $item['createdAt'] = $row['created_at'];
    $item['updatedAt'] = $row['updated_at'];
    return $item;
}

try {
    if ($action === 'login') {
        $usuario = trim($body['usuario'] ?? '');
        $senha = (string)($body['senha'] ?? '');
        $stmt = $pdo->prepare('SELECT id, nome, usuario, senha_hash, perfil FROM usuarios WHERE usuario = ? AND ativo = 1 LIMIT 1');
        $stmt->execute([$usuario]);
        $user = $stmt->fetch();
        if (!$user || !password_verify($senha, $user['senha_hash'])) {
            vg_json(false, null, 'Usuário ou senha inválidos.');
        }
        unset($user['senha_hash']);
        $_SESSION['user'] = $user;
        vg_json(true, $user);
    }

    if ($action === 'logout') {
        $_SESSION = [];
        session_destroy();
        vg_json(true, true);
    }

    if ($action === 'state') {
        $state = [];
        foreach (vg_allowed_modules() as $module) {
            $stmt = $pdo->prepare('SELECT id, data_json, created_at, updated_at FROM portal_conteudo WHERE modulo = ? ORDER BY ordem ASC, created_at DESC');
            $stmt->execute([$module]);
            $items = array_map('row_to_item', $stmt->fetchAll());
            $state[$module] = in_array($module, ['redirects','config'], true) ? (object)($items[0] ?? []) : $items;
        }
        vg_json(true, $state);
    }

    if ($action === 'list') {
        $module = $body['module'] ?? '';
        vg_require_module($module);
        $stmt = $pdo->prepare('SELECT id, data_json, created_at, updated_at FROM portal_conteudo WHERE modulo = ? ORDER BY ordem ASC, created_at DESC');
        $stmt->execute([$module]);
        vg_json(true, array_map('row_to_item', $stmt->fetchAll()));
    }

    if (!isset($_SESSION['user']) && in_array($action, ['create','update','delete','sync'], true)) {
        vg_json(false, null, 'Sessão administrativa expirada. Faça login novamente.');
    }

    if ($action === 'create') {
        $module = $body['module'] ?? '';
        vg_require_module($module);
        $item = is_array($body['item'] ?? null) ? $body['item'] : [];
        $id = $item['id'] ?? uniqid(substr($module, 0, 3) . '_', true);
        $stmt = $pdo->prepare('INSERT INTO portal_conteudo (id, modulo, titulo, status, data_json) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE titulo=VALUES(titulo), status=VALUES(status), data_json=VALUES(data_json), updated_at=CURRENT_TIMESTAMP');
        $stmt->execute([$id, $module, $item['titulo'] ?? $item['nome'] ?? $item['numero'] ?? $id, $item['status'] ?? 'Publicado', json_encode($item, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)]);
        vg_json(true, $item + ['id' => $id]);
    }

    if ($action === 'update') {
        $module = $body['module'] ?? '';
        $id = $body['id'] ?? '';
        vg_require_module($module);
        $stmt = $pdo->prepare('SELECT data_json FROM portal_conteudo WHERE id = ? AND modulo = ?');
        $stmt->execute([$id, $module]);
        $current = json_decode((string)$stmt->fetchColumn(), true) ?: [];
        $item = array_merge($current, is_array($body['item'] ?? null) ? $body['item'] : []);
        $stmt = $pdo->prepare('UPDATE portal_conteudo SET titulo = ?, status = ?, data_json = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND modulo = ?');
        $stmt->execute([$item['titulo'] ?? $item['nome'] ?? $item['numero'] ?? $id, $item['status'] ?? 'Publicado', json_encode($item, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $id, $module]);
        vg_json(true, $item + ['id' => $id]);
    }

    if ($action === 'delete') {
        $module = $body['module'] ?? '';
        $id = $body['id'] ?? '';
        vg_require_module($module);
        $stmt = $pdo->prepare('DELETE FROM portal_conteudo WHERE id = ? AND modulo = ?');
        $stmt->execute([$id, $module]);
        vg_json(true, true);
    }

    vg_json(false, null, 'Ação não encontrada.');
} catch (Throwable $e) {
    vg_json(false, null, $e->getMessage());
}
