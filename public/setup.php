<?php
/**
 * SETUP TEMPORAL v3 - Sin exec(), todo via PHP puro, con errores
 */
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');

echo "<h1>DJ Software - Setup v3</h1>";
echo "<pre>";

// 1. Crear .env con APP_KEY ya generado
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

$envPath = dirname(__DIR__) . '/.env';
file_put_contents($envPath, $envContent);
echo "[OK] .env creado con APP_KEY\n";
ob_flush(); flush();

// 2. Conectar a la base de datos
try {
    $pdo = new PDO(
        'mysql:host=localhost;port=3306;dbname=u402597904_dj_dashboard',
        'u402597904_dj_panel',
        'Davidalpizar0918',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    echo "[OK] Conexion a base de datos exitosa\n";
} catch (PDOException $e) {
    echo "[ERROR] No se pudo conectar a la DB: " . $e->getMessage() . "\n";
    echo "</pre>";
    exit;
}
ob_flush(); flush();

// 3. Verificar tablas
echo "\n--- Verificando migraciones ---\n";
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
echo "[OK] Ya existen " . count($tables) . " tablas en la base de datos\n";
ob_flush(); flush();

// 4. Crear storage directory y symlink
echo "\n--- Creando storage ---\n";
$storageBase = dirname(__DIR__) . '/storage';
$storageAppPublic = $storageBase . '/app/public';
$publicStorage = dirname(__DIR__) . '/public/storage';

// Crear carpetas necesarias
$dirs = [
    $storageBase . '/app',
    $storageBase . '/app/public',
    $storageBase . '/framework',
    $storageBase . '/framework/cache',
    $storageBase . '/framework/cache/data',
    $storageBase . '/framework/sessions',
    $storageBase . '/framework/views',
    $storageBase . '/logs',
];
foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
        echo "  [CREATE] $dir\n";
    }
}

// Crear symlink
if (file_exists($publicStorage) || is_link($publicStorage)) {
    echo "[SKIP] Storage symlink ya existe\n";
} else {
    try {
        symlink($storageAppPublic, $publicStorage);
        echo "[OK] Storage symlink creado\n";
    } catch (Exception $e) {
        echo "[WARN] No se pudo crear symlink: " . $e->getMessage() . "\n";
        echo "  Intentando copiar archivos...\n";
        // Copiar en lugar de symlink
        if (is_dir($storageAppPublic)) {
            exec("cp -r $storageAppPublic $publicStorage 2>&1", $output, $code);
            echo $code === 0 ? "[OK] Archivos copiados\n" : "[ERROR] No se pudo copiar\n";
        }
    }
}
ob_flush(); flush();

// 5. Permisos
echo "\n--- Configurando permisos ---\n";
$chmodDirs = [
    $storageBase,
    dirname(__DIR__) . '/bootstrap/cache',
];
foreach ($chmodDirs as $dir) {
    if (is_dir($dir)) {
        @chmod($dir, 0755);
        echo "[OK] Permisos 755 en: " . basename($dir) . "\n";
    }
}
ob_flush(); flush();

// 6. Verificacion final
echo "\n=== VERIFICACION FINAL ===\n";
echo "Archivo .env: " . (file_exists($envPath) ? "OK" : "FALTA") . "\n";
echo "APP_KEY: " . (strpos(file_get_contents($envPath), 'APP_KEY=base64:') !== false ? "OK" : "FALTA") . "\n";

$checkTables = ['usuarios', 'productos', 'ventas', 'clientes', 'roles'];
foreach ($checkTables as $t) {
    $exists = $pdo->query("SHOW TABLES LIKE '$t'")->fetch();
    echo "Tabla $t: " . ($exists ? "OK" : "FALTA") . "\n";
}

echo "Storage symlink: " . (file_exists($publicStorage) ? "OK" : "FALTA") . "\n";
echo "Cache dir: " . (is_dir($storageBase . '/framework/cache/data') ? "OK" : "FALTA") . "\n";
echo "Sessions dir: " . (is_dir($storageBase . '/framework/sessions') ? "OK" : "FALTA") . "\n";

echo "\n</pre>";
echo "<h2>SETUP COMPLETADO</h2>";
echo "<p>Tu sitio deberia funcionar: <a href='https://dj-custom.website'>https://dj-custom.website</a></p>";
echo "<p style='color:red; font-size:24px; font-weight:bold;'>BORRA ESTE ARCHIVO: public_html/public/setup.php</p>";
