<?php
declare(strict_types=1);
require_once __DIR__ . '/config.php';
ini_set('session.use_strict_mode', '1');
session_name('crafted_session');
session_set_cookie_params([
    'lifetime' => 0, 'path' => '/', 'httponly' => true,
    'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'samesite' => 'Lax'
]);
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $host = app_config('DB_HOST', '127.0.0.1');
        $port = app_config('DB_PORT', '3306');
        $db = app_config('DB_NAME', 'crafted');
        $pdo = new PDO("mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4", app_config('DB_USER', 'root'), app_config('DB_PASS'), [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}
function q(string $sql, array $params = []): PDOStatement { $s = db()->prepare($sql); $s->execute($params); return $s; }
function h(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function money(float|int|string $value): string { return '$' . number_format((float)$value, 2) . ' MXN'; }
function go(string $page, array $args = []): never { header('Location: index.php?' . http_build_query(['page' => $page] + $args)); exit; }
function csrf(): string { return $_SESSION['csrf'] ??= bin2hex(random_bytes(32)); }
function csrf_input(): string { return '<input type="hidden" name="csrf" value="' . h(csrf()) . '">'; }
function require_csrf(): void { if (!hash_equals(csrf(), (string)($_POST['csrf'] ?? ''))) { http_response_code(419); exit('Sesión vencida o formulario inválido (CSRF).'); } }
function flash(string $type, string $message): void { $_SESSION['flash'][] = compact('type', 'message'); }
function current_user(): ?array {
    if (!empty($_SESSION['usuario_id'])) {
        $u = q('SELECT id, nombre, correo, fecha_nacimiento, direccion_postal, tarjeta_ultimos4, rol FROM usuarios WHERE id = ?', [(int)$_SESSION['usuario_id']])->fetch();
        if ($u) return $u;
        unset($_SESSION['usuario_id']);
    }
    if (!empty($_COOKIE['crafted_remember'])) {
        $pieces = explode(':', $_COOKIE['crafted_remember'], 2);
        if (count($pieces) === 2 && ctype_xdigit($pieces[0]) && ctype_xdigit($pieces[1]) && strlen($pieces[0]) === 24 && strlen($pieces[1]) === 64) {
            $token = q('SELECT * FROM sesiones_persistentes WHERE selector = ? AND vence_en > NOW()', [$pieces[0]])->fetch();
            if ($token && hash_equals($token['verificador_hash'], hash('sha256', $pieces[1]))) {
                $_SESSION['usuario_id'] = (int)$token['usuario_id'];
                session_regenerate_id(true);
                // Rotación del token después de cada autenticación automática.
                q('DELETE FROM sesiones_persistentes WHERE id = ?', [$token['id']]);
                remember_user((int)$token['usuario_id']);
                return q('SELECT id, nombre, correo, fecha_nacimiento, direccion_postal, tarjeta_ultimos4, rol FROM usuarios WHERE id = ?', [$_SESSION['usuario_id']])->fetch() ?: null;
            }
        }
        clear_remember_cookie();
    }
    return null;
}
function remember_user(int $uid): void {
    $selector = bin2hex(random_bytes(12)); $verifier = bin2hex(random_bytes(32));
    q('INSERT INTO sesiones_persistentes(usuario_id,selector,verificador_hash,vence_en) VALUES(?,?,?,DATE_ADD(NOW(),INTERVAL 30 DAY))', [$uid,$selector,hash('sha256',$verifier)]);
    setcookie('crafted_remember', "$selector:$verifier", ['expires' => time()+30*86400,'path'=>'/','secure'=>!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off','httponly'=>true,'samesite'=>'Lax']);
}
function clear_remember_cookie(): void {
    setcookie('crafted_remember', '', ['expires'=>time()-3600,'path'=>'/','httponly'=>true,'samesite'=>'Lax','secure'=>!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off']);
}
function require_user(): array { $u = current_user(); if (!$u) { flash('warning', 'Inicia sesión para continuar.'); go('acceso'); } return $u; }
function require_admin(): array { $u = require_user(); if ($u['rol'] !== 'admin') { http_response_code(403); exit('Acceso restringido'); } return $u; }
function count_cart(?array $u): int { return $u ? (int)q('SELECT COALESCE(SUM(cantidad),0) FROM carrito WHERE usuario_id=?', [$u['id']])->fetchColumn() : 0; }
/** Escribe un número sin ceros sobrantes: 4.00000000 -> 4, 2.40 -> 2.4 */
function num_limpio(float $n): string { $t = rtrim(rtrim(number_format($n, 4, '.', ''), '0'), '.'); return $t === '' || $t === '-0' ? '0' : $t; }
/**
 * Unidad en la que se captura un complemento o fibra. La base de datos guarda todo en gramos,
 * pero las vitaminas y minerales se dosifican en miligramos o microgramos; así el formulario
 * muestra "2.4 µg" en lugar de "0.0000024 g".
 * Devuelve unidad, factor (unidad -> gramos), mínimo, máximo y paso en esa unidad.
 */
function unidad_ingrediente(array $ing): array {
    $max = (float)$ing['maximo_g']; $min = (float)$ing['minimo_g'];
    [$unidad, $factor] = $max >= 1 ? ['g', 1.0] : ($max >= 0.001 ? ['mg', 0.001] : ['µg', 0.000001]);
    $minU = round($min / $factor, 4); $maxU = round($max / $factor, 4);
    $multiplo = fn(float $x, float $n): bool => abs($x / $n - round($x / $n)) < 1e-6;
    $paso = 0.1;
    foreach ([100, 50, 10, 5, 1, 0.5, 0.1] as $n) {
        if (($minU <= 0 || $n <= $minU + 1e-9) && $maxU / $n >= 8 - 1e-9 && $multiplo($minU, $n) && $multiplo($maxU, $n)) { $paso = $n; break; }
    }
    return ['unidad' => $unidad, 'factor' => $factor, 'min' => $minU, 'max' => $maxU, 'paso' => $paso];
}
function product_image(array $p): string {
    $foto = (string)($p['foto'] ?? '');
    // Solo rutas internas generadas o subidas: evita esquemas peligrosos o rutas externas.
    return preg_match('~^(assets/img/[a-z0-9_\-]+\.svg|uploads/[a-z0-9_\-]+\.(jpg|jpeg|png|webp))$~i', $foto) ? $foto : 'assets/img/producto.svg';
}
function post_str(string $key, int $limit=255): string { return mb_substr(trim((string)($_POST[$key] ?? '')), 0, $limit); }
function render_header(string $title = ''): void {
    $u = current_user(); $active = (string)($_GET['page'] ?? 'inicio');
    ?><!DOCTYPE html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title><?=h($title ? "$title | crafted" : 'crafted | nutrición a tu medida')?></title>
    <meta name="description" content="crafted: explora ingredientes y personaliza una fórmula de proteína. Prototipo académico.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.9/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet"></head><body>
    <header class="site-header sticky-top"><nav class="navbar navbar-expand-lg container py-3" aria-label="Navegación principal">
    <a class="navbar-brand brand" href="index.php">crafted <span class="brand-leaf">♧</span></a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false" aria-label="Abrir menú"><span class="navbar-toggler-icon"></span></button>
    <div class="collapse navbar-collapse" id="mainNav"><ul class="navbar-nav mx-auto gap-lg-3">
    <?php foreach (['inicio'=>'Inicio','catalogo'=>'Catálogo','ingredientes'=>'Ingredientes','crear'=>'Crea tu proteína','contacto'=>'Nosotros'] as $path=>$label): ?>
        <li class="nav-item"><a class="nav-link <?= $active===$path?'active':'' ?>" href="index.php?page=<?=h($path)?>"><?=h($label)?></a></li>
    <?php endforeach ?></ul><div class="d-flex align-items-center gap-3 nav-actions">
    <?php if ($u): ?><a href="index.php?page=perfil" class="nav-link text-nowrap">Hola, <?=h(explode(' ', $u['nombre'])[0])?></a>
    <?php if ($u['rol']==='admin'): ?><a class="nav-link" href="index.php?page=admin">Admin</a><?php endif ?>
    <?php else: ?><a href="index.php?page=acceso" class="nav-link">Entrar</a><?php endif ?>
    <a class="nav-cart" href="index.php?page=carrito" aria-label="Carrito">Bolsa <span class="badge rounded-pill bg-brand"><?=count_cart($u)?></span></a>
    </div></div></nav></header>
    <?php if (APP_DEMO): ?><div class="demo-band text-center">Prototipo académico · Compras simuladas · No se fabrican suplementos desde esta web</div><?php endif ?>
    <?php foreach ($_SESSION['flash'] ?? [] as $f): ?><div class="container mt-3"><div class="alert alert-<?=h($f['type'])?> alert-dismissible fade show" role="alert"><?=h($f['message'])?><button class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button></div></div><?php endforeach; unset($_SESSION['flash']); ?>
    <?php
}
function render_footer(): void { ?>
<footer class="footer mt-5 pt-5 pb-4"><div class="container"><div class="row g-4"><div class="col-md-5"><div class="brand fs-2">crafted <span class="brand-leaf">♧</span></div><p class="text-muted mt-2">Tu proteína, hecha por ti. Ingredientes con trazabilidad y personalización responsable.</p></div><div class="col-md-3"><h6>Explora</h6><a href="index.php?page=catalogo">Catálogo</a><a href="index.php?page=ingredientes">Ingredientes</a><a href="index.php?page=crear">Crear fórmula</a></div><div class="col-md-4"><h6>Atención</h6><a href="index.php?page=contacto">Contacto y aviso de privacidad</a><p class="small text-muted mt-3">Proyecto educativo. Información nutricional ilustrativa; ninguna fórmula es una indicación médica.</p></div></div><hr><small class="text-muted">© <?=date('Y')?> crafted · Diseñado con Bootstrap y PHP</small></div></footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.9/dist/js/bootstrap.bundle.min.js"></script><script src="assets/js/app.js" defer></script></body></html><?php }
