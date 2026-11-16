<?php
// Modifica las variables de entorno o estos valores para conectar MySQL/MariaDB.
const APP_NAME = 'crafted';
const APP_DEMO = true; // Checkout simulado: NO realiza cargos ni produce suplementos.
function app_config(string $key, string $fallback = ''): string {
    $value = getenv($key);
    return $value === false ? $fallback : $value;
}
