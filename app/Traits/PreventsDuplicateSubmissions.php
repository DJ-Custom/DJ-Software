<?php

namespace App\Traits;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Trait para controladores que requieren protección extra contra duplicados.
 * Permite usar cache locks y transacciones de base de datos.
 */
trait PreventsDuplicateSubmissions
{
    /**
     * Ejecuta una operación dentro de una transacción de DB y un cache lock.
     * Si ya existe un lock activo para esta clave, retorna el valor por defecto.
     *
     * @param string $lockKey Clave única para el lock
     * @param callable $callback Función a ejecutar protegida
     * @param mixed $alreadyRunningValue Valor a retornar si ya hay un proceso en ejecución
     * @param int $lockSeconds Segundos que dura el lock
     * @return mixed
     */
    protected function withDuplicateLock(string $lockKey, callable $callback, mixed $alreadyRunningValue = null, int $lockSeconds = 30): mixed
    {
        $cacheKey = 'controller_lock:' . $lockKey;

        // Intentar adquirir lock atómico usando cache
        $lockAcquired = Cache::add($cacheKey, now()->toDateTimeString(), $lockSeconds);

        if (!$lockAcquired) {
            Log::warning('Duplicate submission blocked by controller lock', ['key' => $lockKey]);
            return $alreadyRunningValue;
        }

        try {
            return DB::transaction($callback);
        } finally {
            // Liberar lock inmediatamente al terminar
            Cache::forget($cacheKey);
        }
    }

    /**
     * Verifica si ya existe un registro con los mismos datos críticos
     * dentro de un rango de tiempo reciente (protección contra race conditions).
     *
     * @param string $table Nombre de la tabla
     * @param array $conditions Columnas/valores para WHERE
     * @param int $secondsRange Ventana de tiempo en segundos
     * @return bool True si existe un registro reciente
     */
    protected function existsRecentRecord(string $table, array $conditions, int $secondsRange = 10): bool
    {
        $query = DB::table($table);

        foreach ($conditions as $column => $value) {
            $query->where($column, $value);
        }

        $query->where('created_at', '>=', now()->subSeconds($secondsRange));

        return $query->exists();
    }

    /**
     * Genera una clave de lock basada en el usuario autenticado y la acción.
     *
     * @param string $action Identificador de la acción (ej: 'crear_producto')
     * @param array $extra Datos extra para hacer única la clave
     * @return string
     */
    protected function generateLockKey(string $action, array $extra = []): string
    {
        $userId = auth()->id() ?? 'guest';
        $extraHash = md5(json_encode($extra));
        return "{$userId}:{$action}:{$extraHash}";
    }
}
