<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';
$allowed = ['inicio','catalogo','detalle','ingredientes','registro','acceso','perfil','cuestionario','recomendaciones','crear','carrito','pedidos','contacto','admin','admin_producto','admin_pedidos'];
$page = (string)($_GET['page'] ?? 'inicio');
if (!in_array($page, $allowed, true)) { http_response_code(404); $page='404'; }
$titles = ['inicio'=>'Inicio','catalogo'=>'Catálogo','detalle'=>'Producto','ingredientes'=>'Ingredientes','registro'=>'Crear cuenta','acceso'=>'Inicia sesión','perfil'=>'Mi perfil','cuestionario'=>'Mi cuestionario','recomendaciones'=>'Mis recomendaciones','crear'=>'Crea tu proteína','carrito'=>'Mi carrito','pedidos'=>'Mis pedidos','contacto'=>'Contacto','admin'=>'Administración','admin_producto'=>'Editar producto','admin_pedidos'=>'Historial de compras','404'=>'No encontrada'];
// Verificar el acceso antes de enviar HTML o encabezados HTTP.
if (in_array($page, ['perfil','cuestionario','recomendaciones','crear','carrito','pedidos'], true)) require_user();
if (in_array($page, ['admin','admin_producto','admin_pedidos'], true)) require_admin();
render_header($titles[$page]);
include __DIR__ . '/views/' . $page . '.php';
render_footer();
