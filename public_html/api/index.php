<?php
declare(strict_types=1);

ini_set('display_errors','0');
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: SAMEORIGIN');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: geolocation=(), microphone=(), camera=()');

session_set_cookie_params(['lifetime'=>0,'path'=>'/','secure'=>isset($_SERVER['HTTPS']),'httponly'=>true,'samesite'=>'Lax']);
session_start();

$configFile = __DIR__ . '/config/config.php';
if (!file_exists($configFile)) {
    http_response_code(503);
    echo json_encode(['ok'=>false,'message'=>'Instalação pendente: copie api/config/config.example.php para api/config/config.php e preencha os dados do banco.']);
    exit;
}
$config = require $configFile;
if (($config['db_name'] ?? '') === 'preencher_aqui' || ($config['db_user'] ?? '') === 'preencher_aqui') {
    http_response_code(503);
    echo json_encode(['ok'=>false,'message'=>'Configuração pendente: edite api/config/config.php com DB_HOST, DB_NAME, DB_USER, DB_PASS e BASE_URL.']);
    exit;
}

function respond($data, int $status=200): void { http_response_code($status); echo json_encode($data, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES); exit; }
function body(): array { $raw=file_get_contents('php://input'); $json=json_decode($raw?:'{}', true); return is_array($json)?$json:[]; }
function db(): PDO { global $config; static $pdo=null; if($pdo) return $pdo; $dsn='mysql:host='.$config['db_host'].';dbname='.$config['db_name'].';charset=utf8mb4'; try{$pdo=new PDO($dsn,$config['db_user'],$config['db_pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]); return $pdo;}catch(Throwable $e){respond(['ok'=>false,'message'=>'Não foi possível conectar ao banco. Verifique api/config/config.php.'],500);} }
function user(): ?array { return $_SESSION['user'] ?? null; }
function require_user(): array { $u=user(); if(!$u) respond(['ok'=>false,'message'=>'Login obrigatório.'],401); return $u; }
function csrf_token(): string { if(empty($_SESSION['csrf'])) $_SESSION['csrf']=bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function require_csrf(): void { $h=$_SERVER['HTTP_X_CSRF_TOKEN'] ?? ''; if(!$h || !hash_equals($_SESSION['csrf'] ?? '', $h)) respond(['ok'=>false,'message'=>'Token CSRF inválido. Atualize a página e tente novamente.'],419); }
function clean(?string $v): string { return trim((string)$v); }
function now(): string { return date('Y-m-d H:i:s'); }
function slugify(string $s): string { $s=iconv('UTF-8','ASCII//TRANSLIT//IGNORE',$s); $s=strtolower(preg_replace('/[^a-zA-Z0-9]+/','-', $s)); return trim($s,'-') ?: bin2hex(random_bytes(4)); }
function audit(string $action,string $entity,int $id=0,$before=null,$after=null): void { try{$u=user(); $st=db()->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,before_json,after_json,ip,user_agent,created_at) VALUES(?,?,?,?,?,?,?,?,?)'); $st->execute([$u['id']??null,$action,$entity,$id,json_encode($before,JSON_UNESCAPED_UNICODE),json_encode($after,JSON_UNESCAPED_UNICODE),$_SERVER['REMOTE_ADDR']??'',substr($_SERVER['HTTP_USER_AGENT']??'',0,250),now()]);}catch(Throwable $e){} }
function version_row(string $entity,int $id,array $data): void { try{$u=user(); $st=db()->prepare('INSERT INTO content_versions(entity_type,entity_id,data_json,user_id,created_at) VALUES(?,?,?,?,?)'); $st->execute([$entity,$id,json_encode($data,JSON_UNESCAPED_UNICODE),$u['id']??null,now()]);}catch(Throwable $e){} }

$tables = [
 'news'=>['table'=>'news','public'=>'published','order'=>'published_at DESC, id DESC','fields'=>['title','slug','summary','content','category','status','featured_image_id','published_at']],
 'laws'=>['table'=>'laws','public'=>'published','order'=>'year DESC, number DESC','fields'=>['type','number','year','description','status','file_id','published_at']],
 'bids'=>['table'=>'bids','public'=>'published','order'=>'opening_date DESC, id DESC','fields'=>['title','modality','number','opening_date','amount','status','file_id','published_at']],
 'contracts'=>['table'=>'contracts','public'=>'published','order'=>'signed_at DESC, id DESC','fields'=>['bid_id','title','number','supplier','amount','signed_at','status','file_id']],
 'documents'=>['table'=>'documents','public'=>'published','order'=>'published_at DESC, id DESC','fields'=>['title','category','description','status','file_id','published_at']],
 'works'=>['table'=>'works','public'=>'published','order'=>'id DESC','fields'=>['title','description','location','budget','progress','status','image_id','published_at']],
 'faqs'=>['table'=>'faqs','public'=>'1','order'=>'sort_order ASC, id DESC','fields'=>['question','answer','category','sort_order','is_published']],
 'galleries'=>['table'=>'galleries','public'=>'published','order'=>'id DESC','fields'=>['title','description','status','cover_file_id','published_at']],
 'gallery_images'=>['table'=>'gallery_images','public'=>'1','order'=>'sort_order ASC, id DESC','fields'=>['gallery_id','file_id','caption','sort_order']],
 'services'=>['table'=>'services','public'=>'1','order'=>'sort_order ASC, id DESC','fields'=>['title','description','external_url','icon','is_active','sort_order']],
 'secretariats'=>['table'=>'secretariats','public'=>'1','order'=>'name ASC','fields'=>['name','responsible','phone','email','address','is_active']],
 'redirects'=>['table'=>'redirects','public'=>'1','order'=>'label ASC','fields'=>['label','slug','url','is_active']],
 'integrations'=>['table'=>'external_integrations','public'=>'1','order'=>'name ASC','fields'=>['name','slug','url','description','is_active']],
 'polls'=>['table'=>'polls','public'=>'published','order'=>'id DESC','fields'=>['question','options_json','status','starts_at','ends_at']],
 'users'=>['table'=>'users','public'=>'0','order'=>'name ASC','fields'=>['name','email','password','role','is_active']]
];
function map_item(array $r): array { global $config; foreach(['featured_image','file','image','cover_file'] as $k){ if(isset($r[$k.'_path'])) $r[$k.'_url'] = $r[$k.'_path'] ? rtrim($config['upload_url'],'/').'/'.$r[$k.'_path'] : null; } return $r; }
function list_records(string $key, bool $public=false): void { global $tables; if(!isset($tables[$key])) respond(['ok'=>false,'message'=>'Módulo inválido.'],404); $m=$tables[$key]; $where='deleted_at IS NULL'; if($public){ if($m['public']==='published') $where.=" AND status='published'"; elseif($m['public']==='1'){ if(in_array('is_published',$m['fields'],true)) $where.=' AND is_published=1'; if(in_array('is_active',$m['fields'],true)) $where.=' AND is_active=1'; } else respond(['ok'=>false,'message'=>'Recurso privado.'],403); }
 $joins=''; $select=$m['table'].'.*'; if(in_array('featured_image_id',$m['fields'],true)){$joins.=' LEFT JOIN files f1 ON f1.id='.$m['table'].'.featured_image_id';$select.=',f1.path AS featured_image_path';} if(in_array('file_id',$m['fields'],true)){$joins.=' LEFT JOIN files f2 ON f2.id='.$m['table'].'.file_id';$select.=',f2.path AS file_path,f2.original_name AS file_name';} if(in_array('image_id',$m['fields'],true)){$joins.=' LEFT JOIN files f3 ON f3.id='.$m['table'].'.image_id';$select.=',f3.path AS image_path';} if(in_array('cover_file_id',$m['fields'],true)){$joins.=' LEFT JOIN files f4 ON f4.id='.$m['table'].'.cover_file_id';$select.=',f4.path AS cover_file_path';}
 $sql='SELECT '.$select.' FROM '.$m['table'].$joins.' WHERE '.$where.' ORDER BY '.$m['order'].' LIMIT 200'; $rows=array_map('map_item', db()->query($sql)->fetchAll()); if($key==='galleries' && $public){ foreach($rows as &$gal){ $st=db()->prepare('SELECT gi.*, f.path AS file_path, f.original_name AS file_name FROM gallery_images gi JOIN files f ON f.id=gi.file_id WHERE gi.gallery_id=? AND gi.deleted_at IS NULL ORDER BY gi.sort_order ASC, gi.id ASC'); $st->execute([$gal['id']]); $gal['images']=array_map('map_item',$st->fetchAll()); } } respond(['ok'=>true,'data'=>$rows]); }
function get_record(string $key,int $id): void { global $tables; require_user(); $m=$tables[$key]??null; if(!$m) respond(['ok'=>false,'message'=>'Módulo inválido.'],404); $st=db()->prepare('SELECT * FROM '.$m['table'].' WHERE id=? AND deleted_at IS NULL'); $st->execute([$id]); $r=$st->fetch(); if(!$r) respond(['ok'=>false,'message'=>'Registro não encontrado.'],404); respond(['ok'=>true,'data'=>$r]); }
function save_record(string $key, ?int $id=null): void { global $tables; require_user(); require_csrf(); $m=$tables[$key]??null; if(!$m) respond(['ok'=>false,'message'=>'Módulo inválido.'],404); $in=body(); $data=[]; foreach($m['fields'] as $f){ if(array_key_exists($f,$in)) $data[$f]=is_string($in[$f])?clean($in[$f]):$in[$f]; } if($key==='users'){ if(!empty($data['password'])){ $data['password_hash']=password_hash((string)$data['password'], PASSWORD_DEFAULT); } unset($data['password']); if(!$id && empty($data['password_hash'])) respond(['ok'=>false,'message'=>'Senha obrigatória para novo usuário.'],422); } if($key==='news' && empty($data['slug']) && !empty($data['title'])) $data['slug']=slugify($data['title']); if(isset($data['status']) && $data['status']==='published' && empty($data['published_at'])) $data['published_at']=now(); $pdo=db(); if($id){ $st=$pdo->prepare('SELECT * FROM '.$m['table'].' WHERE id=?');$st->execute([$id]);$before=$st->fetch(); if(!$before) respond(['ok'=>false,'message'=>'Registro não encontrado.'],404); $sets=[]; foreach($data as $f=>$v)$sets[]="$f=?"; $data['updated_at']=now(); $sets[]='updated_at=?'; $vals=array_values($data); $vals[]=$id; $pdo->prepare('UPDATE '.$m['table'].' SET '.implode(',',$sets).' WHERE id=?')->execute($vals); audit('update',$key,$id,$before,$data); version_row($key,$id,$data); respond(['ok'=>true,'id'=>$id]); } else { $data['created_at']=now(); $cols=array_keys($data); $qs=array_fill(0,count($cols),'?'); $pdo->prepare('INSERT INTO '.$m['table'].'('.implode(',',$cols).') VALUES('.implode(',',$qs).')')->execute(array_values($data)); $newId=(int)$pdo->lastInsertId(); audit('create',$key,$newId,null,$data); version_row($key,$newId,$data); respond(['ok'=>true,'id'=>$newId],201); } }
function delete_record(string $key,int $id): void { global $tables; require_user(); require_csrf(); $m=$tables[$key]??null; if(!$m) respond(['ok'=>false,'message'=>'Módulo inválido.'],404); db()->prepare('UPDATE '.$m['table'].' SET deleted_at=?, updated_at=? WHERE id=?')->execute([now(),now(),$id]); audit('delete',$key,$id); respond(['ok'=>true]); }
function settings_public(): void { $rows=db()->query("SELECT setting_key, setting_value FROM settings WHERE is_public=1")->fetchAll(); $out=[]; foreach($rows as $r)$out[$r['setting_key']]=$r['setting_value']; respond(['ok'=>true,'data'=>$out]); }
function settings_admin(): void { require_user(); $rows=db()->query("SELECT setting_key, setting_value, is_public FROM settings ORDER BY setting_key")->fetchAll(); respond(['ok'=>true,'data'=>$rows]); }
function settings_save(): void { require_user(); require_csrf(); $in=body(); $pdo=db(); foreach(($in['settings']??[]) as $k=>$v){ $st=$pdo->prepare('INSERT INTO settings(setting_key,setting_value,is_public,updated_at) VALUES(?,?,1,?) ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value),updated_at=VALUES(updated_at)'); $st->execute([clean($k),clean((string)$v),now()]); audit('update','settings',0,null,[$k=>$v]); } respond(['ok'=>true]); }
function upload_file(): void { global $config; require_user(); require_csrf(); if(empty($_FILES['file'])) respond(['ok'=>false,'message'=>'Nenhum arquivo enviado.'],422); $f=$_FILES['file']; if($f['error']!==UPLOAD_ERR_OK) respond(['ok'=>false,'message'=>'Falha no upload.'],422); $ext=strtolower(pathinfo($f['name'],PATHINFO_EXTENSION)); $allowed=['jpg','jpeg','png','webp','pdf','doc','docx','xls','xlsx','csv']; if(!in_array($ext,$allowed,true)) respond(['ok'=>false,'message'=>'Tipo de arquivo não permitido.'],422); if($f['size']>15*1024*1024) respond(['ok'=>false,'message'=>'Arquivo maior que 15MB.'],422); $danger=['php','phtml','js','html','htm','exe','sh','phar']; if(in_array($ext,$danger,true)) respond(['ok'=>false,'message'=>'Arquivo perigoso bloqueado.'],422); $dir=rtrim($config['upload_dir'],'/').'/'.date('Y/m'); if(!is_dir($dir)) mkdir($dir,0755,true); $name=slugify(pathinfo($f['name'],PATHINFO_FILENAME)).'-'.bin2hex(random_bytes(6)).'.'.$ext; $dest=$dir.'/'.$name; if(!move_uploaded_file($f['tmp_name'],$dest)) respond(['ok'=>false,'message'=>'Não foi possível salvar o arquivo.'],500); $rel=date('Y/m').'/'.$name; $mime=mime_content_type($dest) ?: $f['type']; $st=db()->prepare('INSERT INTO files(original_name,stored_name,mime_type,size,path,public_url,uploaded_by,created_at) VALUES(?,?,?,?,?,?,?,?)'); $st->execute([$f['name'],$name,$mime,$f['size'],$rel,rtrim($config['upload_url'],'/').'/'.$rel,user()['id'],now()]); $id=(int)db()->lastInsertId(); audit('upload','files',$id); respond(['ok'=>true,'data'=>['id'=>$id,'url'=>rtrim($config['upload_url'],'/').'/'.$rel,'path'=>$rel,'name'=>$f['name']]],201); }
function login(): void { require_csrf(); $in=body(); $email=clean($in['email']??''); $pass=(string)($in['password']??''); $st=db()->prepare('SELECT * FROM users WHERE email=? AND is_active=1 AND deleted_at IS NULL'); $st->execute([$email]); $u=$st->fetch(); if(!$u || !password_verify($pass,$u['password_hash'])) respond(['ok'=>false,'message'=>'E-mail ou senha inválidos.'],401); session_regenerate_id(true); $_SESSION['user']=['id'=>(int)$u['id'],'name'=>$u['name'],'email'=>$u['email'],'role'=>$u['role']]; csrf_token(); db()->prepare('UPDATE users SET last_login_at=? WHERE id=?')->execute([now(),$u['id']]); audit('login','users',(int)$u['id']); respond(['ok'=>true,'user'=>$_SESSION['user'],'csrf'=>csrf_token()]); }
function logout(): void { audit('logout','users',user()['id']??0); $_SESSION=[]; session_destroy(); respond(['ok'=>true]); }
function me(): void { respond(['ok'=>true,'user'=>user(),'csrf'=>csrf_token()]); }
function ouvidoria_create(): void { $in=body(); $protocol='VGRP'.date('Ymd').strtoupper(substr(bin2hex(random_bytes(4)),0,8)); $st=db()->prepare('INSERT INTO manifestations(protocol,type,subject,description,citizen_name,citizen_email,citizen_phone,status,priority,created_at,due_at) VALUES(?,?,?,?,?,?,?,?,?,?,DATE_ADD(NOW(), INTERVAL 20 DAY))'); $st->execute([$protocol,clean($in['type']??'SIC'),clean($in['subject']??''),clean($in['description']??''),clean($in['citizen_name']??''),clean($in['citizen_email']??''),clean($in['citizen_phone']??''),'open','normal',now()]); respond(['ok'=>true,'protocol'=>$protocol],201); }
function ouvidoria_check(string $protocol): void { $st=db()->prepare('SELECT protocol,type,subject,status,created_at,closed_at FROM manifestations WHERE protocol=?'); $st->execute([$protocol]); $m=$st->fetch(); if(!$m) respond(['ok'=>false,'message'=>'Protocolo não encontrado.'],404); $st=db()->prepare('SELECT message,is_public,created_at FROM manifestation_messages WHERE manifestation_id=(SELECT id FROM manifestations WHERE protocol=?) AND is_public=1 ORDER BY id'); $st->execute([$protocol]); $m['messages']=$st->fetchAll(); respond(['ok'=>true,'data'=>$m]); }
function ouvidoria_admin_list(): void { require_user(); $rows=db()->query('SELECT * FROM manifestations ORDER BY id DESC LIMIT 200')->fetchAll(); respond(['ok'=>true,'data'=>$rows]); }
function ouvidoria_reply(int $id): void { require_user(); require_csrf(); $in=body(); $msg=clean($in['message']??''); if($msg==='') respond(['ok'=>false,'message'=>'Informe a resposta.'],422); db()->prepare('INSERT INTO manifestation_messages(manifestation_id,user_id,message,is_public,created_at) VALUES(?,?,?,?,?)')->execute([$id,user()['id'],$msg,1,now()]); db()->prepare('UPDATE manifestations SET status=?, updated_at=?, closed_at=IF(?="closed",NOW(),closed_at) WHERE id=?')->execute([clean($in['status']??'answered'),now(),clean($in['status']??'answered'),$id]); audit('reply','manifestations',$id,null,['message'=>$msg]); respond(['ok'=>true]); }

$path=parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '';
$script=dirname($_SERVER['SCRIPT_NAME']); if(str_starts_with($path,$script)) $path=substr($path,strlen($script)); $path='/'.trim($path,'/'); if($path==='/'||$path==='') $path='/index';
$method=$_SERVER['REQUEST_METHOD'];
if($method==='OPTIONS') respond(['ok'=>true]);
try{
 if($path==='/admin/csrf' && $method==='GET') me();
 if($path==='/admin/login' && $method==='POST') login();
 if($path==='/admin/logout' && $method==='POST') logout();
 if($path==='/admin/me' && $method==='GET') me();
 if($path==='/admin/upload' && $method==='POST') upload_file();
 if($path==='/public/settings' && $method==='GET') settings_public();
 if($path==='/admin/settings' && $method==='GET') settings_admin();
 if($path==='/admin/settings' && $method==='PUT') settings_save();
 if($path==='/public/ouvidoria' && $method==='POST') ouvidoria_create();
 if(preg_match('#^/public/ouvidoria/([A-Za-z0-9-]+)$#',$path,$mm) && $method==='GET') ouvidoria_check($mm[1]);
 if($path==='/admin/ouvidoria' && $method==='GET') ouvidoria_admin_list();
 if(preg_match('#^/admin/ouvidoria/(\d+)/reply$#',$path,$mm) && $method==='POST') ouvidoria_reply((int)$mm[1]);
 if(preg_match('#^/public/([a-z_]+)$#',$path,$mm) && $method==='GET') list_records($mm[1],true);
 if(preg_match('#^/admin/([a-z_]+)$#',$path,$mm) && $method==='GET') list_records($mm[1],false);
 if(preg_match('#^/admin/([a-z_]+)$#',$path,$mm) && $method==='POST') save_record($mm[1]);
 if(preg_match('#^/admin/([a-z_]+)/(\d+)$#',$path,$mm) && $method==='GET') get_record($mm[1],(int)$mm[2]);
 if(preg_match('#^/admin/([a-z_]+)/(\d+)$#',$path,$mm) && in_array($method,['PUT','PATCH'],true)) save_record($mm[1],(int)$mm[2]);
 if(preg_match('#^/admin/([a-z_]+)/(\d+)$#',$path,$mm) && $method==='DELETE') delete_record($mm[1],(int)$mm[2]);
 respond(['ok'=>false,'message'=>'Rota não encontrada: '.$path],404);
}catch(Throwable $e){ respond(['ok'=>false,'message'=>'Erro interno no servidor.'],500); }
