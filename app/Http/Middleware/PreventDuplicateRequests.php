<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware que previene requests duplicados usando Idempotency-Key.
 * Si llega el mismo Idempotency-Key dentro del tiempo de gracia,
 * retorna 429 Too Many Requests.
 */
class PreventDuplicateRequests
{
    /**
     * Tiempo de bloqueo en segundos para la misma clave de idempotencia.
     */
    protected int $lockSeconds = 30;

    public function handle(Request $request, Closure $next): Response
    {
        // Solo aplicar a métodos de escritura
        if (!in_array($request->method(), ['POST', 'PUT', 'PATCH', 'DELETE'])) {
            return $next($request);
        }

        $idempotencyKey = $request->header('Idempotency-Key');

        // Si no hay clave, generar una a partir de la firma del request
        if (!$idempotencyKey) {
            $idempotencyKey = $this->generateRequestSignature($request);
        }

        $cacheKey = 'idempotency:' . $request->user()?->id . ':' . $idempotencyKey;

        // Intentar obtener lock; si ya existe, request duplicado
        $existing = Cache::get($cacheKey);
        if ($existing !== null) {
            return response()->json([
                'error' => 'La solicitud ya está siendo procesada. Por favor espere.',
                'message' => 'Duplicate request blocked',
            ], 429);
        }

        // Marcar como en proceso antes de continuar
        Cache::put($cacheKey, now()->toDateTimeString(), $this->lockSeconds);

        $response = $next($request);

        // Si la respuesta fue exitosa (2xx), mantener el bloqueo un poco más para
        // prevenir re-submits accidentales. Si fue error, liberar más rápido.
        if ($response->getStatusCode() >= 200 && $response->getStatusCode() < 300) {
            Cache::put($cacheKey, now()->toDateTimeString(), $this->lockSeconds);
        } else {
            // En caso de error, reducir tiempo para permitir reintento rápido
            Cache::put($cacheKey, now()->toDateTimeString(), 5);
        }

        return $response;
    }

    /**
     * Genera una firma del request para usar como clave de idempotencia fallback.
     */
    protected function generateRequestSignature(Request $request): string
    {
        $userId = $request->user()?->id ?? 'guest';
        $path = $request->path();
        $method = $request->method();
        $body = json_encode($request->except(['_token', 'password', 'password_confirmation']));

        return md5("{$userId}:{$method}:{$path}:{$body}");
    }
}
