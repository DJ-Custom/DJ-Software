<?php
/**
 * SETUP TEMPORAL - Ejecutar una vez y borrar después
 */
echo "<h1>DJ Software - Setup</h1>";
echo "<pre>";

// 1. Crear .env
$envContent = <<<'ENV'
APP_NAME="DJ Software"
APP_ENV=production
APP_KEY=
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
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

VITE_APP_NAME="${APP_NAME}"
ENV;

$envPath = dirname(__DIR__) . '/.env';
if (!file_exists($envPath)) {
    file_put_contents($envPath, $envContent);
    echo "[OK] .env creado\n";
} else {
    echo "[SKIP] .env ya existe\n";
}

// 2. Ejecutar comandos artisan
$commands = [
    'key:generate' => 'Generando APP_KEY',
    'config:cache' => 'Cacheando configuracion',
    'route:cache' => 'Cacheando rutas',
    'view:cache' => 'Cacheando vistas',
    'migrate --force' => 'Ejecutando migraciones',
];

foreach ($commands as $cmd => $desc) {
    echo "\n--- $desc ---\n";
    $output = [];
    $returnCode = 0;
    exec("php artisan $cmd 2>&1", $output, $returnCode);
    echo implode("\n", $output);
    if ($returnCode !== 0) {
        echo "\n[ERROR] Codigo de error: $returnCode\n";
    } else {
        echo "\n[OK] Completado\n";
    }
}

// 3. Crear storage symlink
echo "\n--- Creando storage symlink ---\n";
$storagePath = dirname(__DIR__) . '/storage/app/public';
$publicPath = dirname(__DIR__) . '/public/storage';
if (!file_exists($publicPath)) {
    symlink($storagePath, $publicPath);
    echo "[OK] Storage symlink creado\n";
} else {
    echo "[SKIP] Storage symlink ya existe\n";
}

echo "\n</pre>";
echo "<h2>SETUP COMPLETADO</h2>";
echo "<p><strong>IMPORTANTE:</strong> Borra este archivo (setup.php) inmediatamente por seguridad.</p>";
echo "<p>Despues de borrarlo, ve a: <a href='https://dj-custom.website'>https://dj-custom.website</a></p>";
echo "<p style='color:red; font-size:20px;'>BORRA ESTE ARCHIVO AHORA: public/setup.php</p>";
