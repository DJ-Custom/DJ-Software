<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');
echo "<h1>DJ Software - Fix</h1><pre>";
ob_flush(); flush();

$base = dirname(__DIR__);

// 1. Fix .env - APP_DEBUG=true temporalmente + SESSION_DOMAIN
$envPath = $base . '/.env';
$env = file_get_contents($envPath);
$env = str_replace('APP_DEBUG=false', 'APP_DEBUG=true', $env);
$env = str_replace('SESSION_DOMAIN=null', 'SESSION_DOMAIN=' . $_SERVER['HTTP_HOST'], $env);
file_put_contents($envPath, $env);
echo "[OK] .env actualizado (APP_DEBUG=true, SESSION_DOMAIN configurado)\n";
ob_flush(); flush();

// 2. Crear storage/logs
$logDir = $base . '/storage/logs';
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
    echo "[OK] storage/logs/ creado\n";
} else {
    echo "[OK] storage/logs/ ya existe\n";
}
@chmod($logDir, 0755);

// 3. Limpiar TODOS los caches
$caches = [
    $base . '/bootstrap/cache/config.php',
    $base . '/bootstrap/cache/routes-v7.php',
    $base . '/bootstrap/cache/services.php',
    $base . '/bootstrap/cache/events.php',
];
foreach ($caches as $c) {
    if (file_exists($c)) {
        unlink($c);
        echo "[DELETE] " . basename($c) . "\n";
    }
}

// Limpiar directorios de cache
$cacheDirs = [
    $base . '/storage/framework/cache',
    $base . '/storage/framework/cache/data',
    $base . '/storage/framework/sessions',
    $base . '/storage/framework/views',
];
foreach ($cacheDirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    // Borrar archivos de cache
    if (is_dir($dir)) {
        $files = glob($dir . '/*');
        foreach ($files as $f) {
            if (is_file($f)) {
                unlink($f);
            }
        }
    }
}
echo "[OK] Todos los caches limpiados\n";
ob_flush(); flush();

// 4. Crear storage symlink manualmente
$src = $base . '/storage/app/public';
$dst = $base . '/public/storage';
if (!is_dir($dst)) {
    mkdir($dst, 0755, true);
}
// Copiar archivos
if (is_dir($src)) {
    $files = is_array(scandir($src)) ? array_diff(scandir($src), ['.', '..']) : [];
    foreach ($files as $f) {
        if ($f !== '.' && $f !== '..') {
            @copy($src . '/' . $f, $dst . '/' . $f);
        }
    }
}
echo "[OK] public/storage/ listo\n";

// 5. Permisos
chmod($base . '/storage', 0755);
chmod($base . '/bootstrap/cache', 0755);
echo "[OK] Permisos 755 configurados\n";
ob_flush(); flush();

// 6. Verificar que Laravel carga correctamente
echo "\n=== TEST LARAVEL ===\n";
try {
    require_once $base . '/vendor/autoload.php';
    $app = require_once $base . '/bootstrap/app.php';
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    
    // Test request to /
    $request = Illuminate\Http\Request::create('/', 'GET');
    $response = $kernel->handle($request);
    $content = $response->getContent();
    
    echo "Status: " . $response->getStatusCode() . "\n";
    echo "Length: " . strlen($content) . " bytes\n";
    
    if (strpos($content, 'app.js') !== false) {
        echo "Blade: RENDERIZADO OK\n";
    } else {
        echo "Blade: NO renderizado\n";
        
        // Mostrar errores si APP_DEBUG=true
        echo "First 500 chars:\n";
        echo htmlspecialchars(substr($content, 0, 500)) . "\n";
        
        // Check log
        $logFile = $base . '/storage/logs/laravel.log';
        if (file_exists($logFile)) {
            $log = file_get_contents($logFile);
            $logSize = strlen($log);
            echo "\nLog size: $logSize bytes\n";
            if ($logSize > 0) {
                echo "Last 500 chars of log:\n";
                echo htmlspecialchars(substr($log, -500)) . "\n";
            }
        }
    }
} catch (Throwable $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . ":" . $e->getLine() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}
ob_flush(); flush();

echo "\n</pre>";
echo "<h2>FIX COMPLETADO</h2>";
echo "<p>Prueba: <a href='https://dj-custom.website/public/'>https://dj-custom.website/public/</a></p>";
echo "<p style='color:red;font-weight:bold;'>BORRA setup.php DESPUES</p>";
