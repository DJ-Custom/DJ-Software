<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');
echo "<h1>DJ Software - Setup v4</h1>";
echo "<pre>";

// 1. Crear .env con APP_KEY
$key = 'base64:' . base64_encode(random_bytes(32));
$envContent = "APP_NAME=\"DJ Software\"
APP_ENV=production
APP_KEY={$key}
APP_DEBUG=false
APP_URL=https://dj-custom.website

APP_LOCALE=es
APP_FALLBACK_LOCALE=es
APP_FAKER_LOCALE=es_ES

APP_MAINTENANCE_DRIVER=file
BCRYPT_ROUNDS=12
LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=u402597904_dj_dashboard
DB_USERNAME=u402597904_dj_panel
DB_PASSWORD=Davidalpizar0918

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null
BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
CACHE_STORE=database

MAIL_MAILER=log
MAIL_SCHEME=null
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS=\"hello@example.com\"
MAIL_FROM_NAME=\"\${APP_NAME}\"
VITE_APP_NAME=\"\${APP_NAME}\"
";

$base = dirname(__DIR__);
$envPath = $base . '/.env';
file_put_contents($envPath, $envContent);
echo "[OK] .env creado con APP_KEY\n";
ob_flush(); flush();

// 2. DB
try {
    $pdo = new PDO('mysql:host=localhost;port=3306;dbname=u402597904_dj_dashboard', 'u402597904_dj_panel', 'Davidalpizar0918', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    echo "[OK] Conexion DB exitosa\n";
} catch (PDOException $e) {
    echo "[ERROR] DB: " . $e->getMessage() . "\n</pre>"; exit;
}
ob_flush(); flush();

// 3. Tablas
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
echo "[OK] " . count($tables) . " tablas en la base de datos\n";
ob_flush(); flush();

// 4. Crear carpetas necesarias (sin symlink)
echo "\n--- Creando carpetas ---\n";
$dirs = [
    $base . '/storage/app',
    $base . '/storage/app/public',
    $base . '/storage/framework',
    $base . '/storage/framework/cache',
    $base . '/storage/framework/cache/data',
    $base . '/storage/framework/sessions',
    $base . '/storage/framework/views',
    $base . '/storage/logs',
    $base . '/bootstrap/cache',
    $base . '/public/storage',
];
foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
        echo "  [CREATE] " . str_replace($base . '/', '', $dir) . "\n";
    }
}
echo "[OK] Carpetas creadas\n";

// Copiar contenido de storage/app/public a public/storage (sin symlink)
$src = $base . '/storage/app/public';
$dst = $base . '/public/storage';
if (is_dir($src)) {
    $files = scandir($src);
    foreach ($files as $f) {
        if ($f !== '.' && $f !== '..') {
            @copy($src . '/' . $f, $dst . '/' . $f);
        }
    }
}
echo "[OK] Storage vinculado (copia directa)\n";
ob_flush(); flush();

// 5. Permisos
echo "\n--- Permisos ---\n";
@chmod($base . '/storage', 0755);
@chmod($base . '/bootstrap/cache', 0755);
echo "[OK] Permisos configurados\n";
ob_flush(); flush();

// 6. Verificacion
echo "\n=== VERIFICACION ===\n";
echo ".env: " . (file_exists($envPath) ? "OK" : "FALTA") . "\n";
echo "APP_KEY: " . (strpos(file_get_contents($envPath), 'APP_KEY=base64:') !== false ? "OK" : "FALTA") . "\n";
foreach (['usuarios','productos','ventas','clientes','roles','configuracion'] as $t) {
    $e = $pdo->query("SHOW TABLES LIKE '$t'")->fetch();
    echo "Tabla $t: " . ($e ? "OK" : "FALTA") . "\n";
}
echo "public/storage: " . (is_dir($base . '/public/storage') ? "OK" : "FALTA") . "\n";

echo "\n</pre>";
echo "<h2>SETUP COMPLETADO</h2>";
echo "<p>Sitio: <a href='https://dj-custom.website/public/'>https://dj-custom.website/public/</a></p>";
echo "<p style='color:red;font-size:24px;font-weight:bold;'>BORRA public_html/public/setup.php AHORA</p>";
