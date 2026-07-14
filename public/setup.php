<?php
/**
 * SETUP TEMPORAL v2 - Sin exec(), todo via PHP puro
 */
echo "<h1>DJ Software - Setup v2</h1>";
echo "<pre>";
ob_flush();
flush();

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

// 3. Ejecutar migraciones leyendo el archivo SQL
echo "\n--- Ejecutando migraciones ---\n";
$migrationFile = dirname(__DIR__) . '/database/migrations/2026_06_11_000000_create_all_tables_consolidated.php';

// Primero, verificar si las tablas ya existen
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
if (count($tables) > 5) {
    echo "[SKIP] Ya existen " . count($tables) . " tablas en la base de datos\n";
} else {
    // Leer el SQL de migracion y ejecutar
    echo "Ejecutando SQL directamente...\n";

    // Usar el archivo SQL exportado si existe
    $sqlFile = dirname(__DIR__) . '/database_export_fixed.sql';
    if (file_exists($sqlFile)) {
        $sql = file_get_contents($sqlFile);
        // Separar por lineas y ejecutar cadaStatement
        $statements = array_filter(
            array_map('trim', explode(';', $sql)),
            function($s) { return !empty($s) && !preg_match('/^--/', $s); }
        );
        $count = 0;
        foreach ($statements as $statement) {
            if (!empty(trim($statement))) {
                try {
                    $pdo->exec($statement);
                    $count++;
                } catch (PDOException $e) {
                    // Ignorar errores de tablas que ya existen
                    if (strpos($e->getMessage(), 'already exists') === false) {
                        echo "Warning: " . $e->getMessage() . "\n";
                    }
                }
            }
        }
        echo "[OK] $count statements ejecutados\n";
    } else {
        echo "[ERROR] No se encontro database_export.sql\n";
        echo "Intentando crear tablas via Laravel migrations...\n";
    }
}

// 4. Crear storage symlink
echo "\n--- Creando storage symlink ---\n";
$storagePath = dirname(__DIR__) . '/storage/app/public';
$publicPath = dirname(__DIR__) . '/public/storage';
if (!file_exists($publicPath)) {
    if (is_dir($storagePath)) {
        symlink($storagePath, $publicPath);
        echo "[OK] Storage symlink creado\n";
    } else {
        echo "[WARN] storage/app/public no existe, creando...\n";
        mkdir($storagePath, 0755, true);
        symlink($storagePath, $publicPath);
        echo "[OK] Storage creado y vinculado\n";
    }
} else {
    echo "[SKIP] Storage symlink ya existe\n";
}

// 5. Crear carpetas de cache
echo "\n--- Preparando cache ---\n";
$cacheDir = dirname(__DIR__) . '/storage/framework/cache/data';
$sessionsDir = dirname(__DIR__) . '/storage/framework/sessions';
$viewsDir = dirname(__DIR__) . '/storage/framework/views';

foreach ([$cacheDir, $sessionsDir, $viewsDir] as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
}
echo "[OK] Carpetas de cache listas\n";

// 6. Verificar que todo funciona
echo "\n--- Verificacion ---\n";
echo "Archivo .env: " . (file_exists($envPath) ? "OK" : "FALTA") . "\n";
echo "APP_KEY: " . (strpos(file_get_contents($envPath), 'APP_KEY=base64:') !== false ? "OK" : "FALTA") . "\n";
echo "Tabla usuarios: " . ($pdo->query("SHOW TABLES LIKE 'usuarios'")->fetch() ? "OK" : "FALTA") . "\n";
echo "Tabla productos: " . ($pdo->query("SHOW TABLES LIKE 'productos'")->fetch() ? "OK" : "FALTA") . "\n";
echo "Storage symlink: " . (file_exists($publicPath) ? "OK" : "FALTA") . "\n";

echo "\n</pre>";
echo "<h2>SETUP COMPLETADO</h2>";
echo "<p>Tu sitio deberia funcionar ahora en: <a href='https://dj-custom.website' style='font-size:20px;'>https://dj-custom.website</a></p>";
echo "<p style='color:red; font-size:24px; font-weight:bold;'>AHORA BORRA ESTE ARCHIVO: public_html/public/setup.php</p>";
echo "<p>Ve a File Manager → public_html → public → setup.php → Delete</p>";
