<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');
echo "<h1>DJ Software - Diagnostico</h1>";
echo "<pre>";

$base = dirname(__DIR__);
$public = $base . '/public';

// 1. Verificar estructura
echo "=== ESTRUCTURA ===\n";
echo "Base dir: $base\n";
echo "Public dir: $public\n";
echo ".env existe: " . (file_exists($base . '/.env') ? 'SI' : 'NO') . "\n";
echo ".htaccess public: " . (file_exists($public . '/.htaccess') ? 'SI' : 'NO') . "\n";
echo "index.php: " . (file_exists($public . '/index.php') ? 'SI' : 'NO') . "\n";

// 2. Verificar build assets
echo "\n=== ASSETS ===\n";
$buildDir = $public . '/build';
echo "build/ existe: " . (is_dir($buildDir) ? 'SI' : 'NO') . "\n";
$manifest = $buildDir . '/manifest.json';
echo "manifest.json: " . (file_exists($manifest) ? 'SI' : 'NO') . "\n";
if (file_exists($manifest)) {
    $m = json_decode(file_get_contents($manifest), true);
    echo "Archivos en manifest: " . count($m) . "\n";
    if (isset($m['resources/js/app.js'])) {
        $appJs = $m['resources/js/app.js']['file'] ?? 'NO ENCONTRADO';
        echo "app.js file: $appJs\n";
        echo "app.js existe: " . (file_exists($public . '/build/' . $appJs) ? 'SI' : 'NO') . "\n";
    }
    if (isset($m['resources/css/app.css'])) {
        $appCss = $m['resources/css/app.css']['file'] ?? 'NO ENCONTRADO';
        echo "app.css file: $appCss\n";
        echo "app.css existe: " . (file_exists($public . '/build/' . $appCss) ? 'SI' : 'NO') . "\n";
    }
}

// 3. Verificar blade template
echo "\n=== BLADE ===\n";
$blade = $base . '/resources/views/app.blade.php';
echo "app.blade.php: " . (file_exists($blade) ? 'SI' : 'NO') . "\n";

// 4. Verificar vendor
echo "\n=== VENDOR ===\n";
echo "vendor/: " . (is_dir($base . '/vendor') ? 'SI' : 'NO') . "\n";
echo "vendor/autoload.php: " . (file_exists($base . '/vendor/autoload.php') ? 'SI' : 'NO') . "\n";
echo "vendor/laravel/: " . (is_dir($base . '/vendor/laravel') ? 'SI' : 'NO') . "\n";

// 5. Verificar storage permisos
echo "\n=== STORAGE ===\n";
$storageDir = $base . '/storage';
echo "storage/: " . (is_dir($storageDir) ? 'SI (perms: ' . substr(sprintf('%o', fileperms($storageDir)), -4) . ')' : 'NO') . "\n";
echo "storage/framework/cache/: " . (is_dir($storageDir . '/framework/cache') ? 'SI' : 'NO') . "\n";
echo "storage/framework/sessions/: " . (is_dir($storageDir . '/framework/sessions') ? 'SI' : 'NO') . "\n";
echo "storage/logs/: " . (is_dir($storageDir . '/logs') ? 'NO' : 'SI') . "\n";

// 6. Verificar rutas web.php
echo "\n=== ROUTES ===\n";
$routeFile = $base . '/routes/web.php';
echo "web.php: " . (file_exists($routeFile) ? 'SI' : 'NO') . "\n";
$routeApi = $base . '/routes/api.php';
echo "api.php: " . (file_exists($routeApi) ? 'SI' : 'NO') . "\n";

// 7. Verificar PHP version y extensiones
echo "\n=== PHP ===\n";
echo "PHP Version: " . phpversion() . "\n";
$exts = ['pdo_mysql', 'mbstring', 'openssl', 'curl', 'json', 'xml', 'bcmath', 'fileinfo', 'zip', 'gd'];
foreach ($exts as $ext) {
    echo "ext $ext: " . (extension_loaded($ext) ? 'OK' : 'FALTA') . "\n";
}

// 8. Verificar APP_KEY
echo "\n=== ENV ===\n";
$envContent = file_get_contents($base . '/.env');
preg_match('/APP_KEY=(.+)/', $envContent, $match);
echo "APP_KEY: " . (!empty($match[1]) ? 'SET (' . substr($match[1], 0, 20) . '...)' : 'NO SET') . "\n";
preg_match('/APP_DEBUG=(.+)/', $envContent, $match);
echo "APP_DEBUG: " . ($match[1] ?? 'NO SET') . "\n";
preg_match('/APP_URL=(.+)/', $envContent, $match);
echo "APP_URL: " . ($match[1] ?? 'NO SET') . "\n";
preg_match('/DB_HOST=(.+)/', $envContent, $match);
echo "DB_HOST: " . ($match[1] ?? 'NO SET') . "\n";
preg_match('/DB_DATABASE=(.+)/', $envContent, $match);
echo "DB_DATABASE: " . ($match[1] ?? 'NO SET') . "\n";

// 9. Intentar cargar Laravel
echo "\n=== LARAVEL ===\n";
try {
    require $base . '/vendor/autoload.php';
    echo "autoload: OK\n";
    $app = require_once $base . '/bootstrap/app.php';
    echo "bootstrap: OK\n";
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    echo "kernel: OK\n";
    
    $request = Illuminate\Http\Request::capture();
    $response = $kernel->handle($request);
    echo "response status: " . $response->getStatusCode() . "\n";
    
    $content = $response->getContent();
    echo "response length: " . strlen($content) . " bytes\n";
    echo "Content-Type: " . $response->headers->get('Content-Type', 'N/A') . "\n";
    
    // Check if blade rendered
    if (strpos($content, 'app.js') !== false || strpos($content, 'vite') !== false) {
        echo "Blade rendered: YES\n";
    } else {
        echo "Blade rendered: NO\n";
        echo "--- First 1000 chars of response ---\n";
        echo htmlspecialchars(substr($content, 0, 1000)) . "\n";
        echo "--- END ---\n";
    }
    
    // Also check the API
    echo "\n=== API TEST ===\n";
    $apiRequest = Illuminate\Http\Request::create('/api/user', 'GET');
    try {
        $apiResponse = $kernel->handle($apiRequest);
        echo "API /api/user status: " . $apiResponse->getStatusCode() . "\n";
        echo "API response: " . substr($apiResponse->getContent(), 0, 200) . "\n";
    } catch (Throwable $e) {
        echo "API error: " . $e->getMessage() . "\n";
    }
} catch (Throwable $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}

echo "\n</pre>";
