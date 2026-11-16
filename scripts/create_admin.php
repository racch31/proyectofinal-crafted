<?php
// CLI: php scripts/create_admin.php "admin@example.com" "UnaContraseñaSegura" "Admin crafted"
if (PHP_SAPI !== 'cli') exit("Sólo CLI\n");
require_once dirname(__DIR__).'/lib.php';
if ($argc < 3 || !filter_var($argv[1], FILTER_VALIDATE_EMAIL) || strlen($argv[2]) < 10) {
    exit("Uso: php scripts/create_admin.php admin@ejemplo.com 'contraseña_de_al_menos_10_caracteres' ['Nombre']\n");
}
$email=mb_strtolower($argv[1]);$name=$argv[3]??'Admin crafted';
$existing=q('SELECT id FROM usuarios WHERE correo=?',[$email])->fetch();
if($existing){q('UPDATE usuarios SET rol=? WHERE id=?',['admin',$existing['id']]);echo "Usuario promovido a admin.\n";}
else {q('INSERT INTO usuarios(nombre,correo,password_hash,fecha_nacimiento,direccion_postal,rol) VALUES(?,?,?,?,?,?)',[$name,$email,password_hash($argv[2],PASSWORD_DEFAULT),'1995-01-01','Dirección demo pendiente','admin']);echo "Administrador creado.\n";}
