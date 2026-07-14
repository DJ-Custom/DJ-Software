<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withBroadcasting(
        __DIR__.'/../routes/channels.php',
        ['prefix' => 'api', 'middleware' => ['auth:sanctum']],
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->statefulApi();
        $middleware->appendToGroup('api', [
            \App\Http\Middleware\SanitizeInput::class,
            \App\Http\Middleware\AuditLog::class,
            \App\Http\Middleware\PreventDuplicateRequests::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->renderable(function (\Throwable $e, $request) {
            if ($request->is('api/*')) {
                $status = method_exists($e, 'getStatusCode') ? $e->getStatusCode() : 500;
                if ($status === 422) {
                    return response()->json([
                        'error' => $e->getMessage() ?: 'Error de validación',
                        'errors' => method_exists($e, 'errors') ? $e->errors() : [],
                    ], 422);
                }
                return response()->json([
                    'error' => $e->getMessage() ?: 'Error del servidor',
                ], $status);
            }
        });
    })->create();
