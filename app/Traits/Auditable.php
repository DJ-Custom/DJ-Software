<?php

namespace App\Traits;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\DB;

trait Auditable
{
    protected array $auditOriginalData = [];

    protected static function bootAuditable(): void
    {
        static::created(function ($model) {
            static::logAudit($model, 'created');
        });

        static::updating(function ($model) {
            $model->auditOriginalData = $model->getOriginal();
        });

        static::updated(function ($model) {
            static::logAudit($model, 'updated');
        });

        static::deleted(function ($model) {
            static::logAudit($model, 'deleted');
        });
    }

    protected static function logAudit($model, string $event): void
    {
        if (!config('app.audit_enabled', true)) {
            return;
        }

        $ignored = $model->getAuditableIgnored();

        $oldValues = null;
        $newValues = null;

        if ($event === 'created') {
            $newValues = collect($model->toArray())
                ->except($ignored)
                ->all();
        }

        if ($event === 'updated') {
            $original = $model->auditOriginalData ?? [];
            $changes = $model->getChanges();

            $oldValues = collect($original)
                ->only(array_keys($changes))
                ->except($ignored)
                ->all();

            $newValues = collect($changes)
                ->except($ignored)
                ->all();

            if (empty($newValues)) {
                return;
            }
        }

        if ($event === 'deleted') {
            $oldValues = collect($model->toArray())
                ->except($ignored)
                ->all();
        }

        $oldValues = static::filterSensitive($oldValues);
        $newValues = static::filterSensitive($newValues);

        $payload = [
            'usuario_id' => Auth::id(),
            'accion' => $event,
            'modulo' => $model->getTable(),
            'descripcion' => $model->getAuditDescription($event),
            'old_values' => $oldValues ? json_encode($oldValues, JSON_UNESCAPED_UNICODE) : null,
            'new_values' => $newValues ? json_encode($newValues, JSON_UNESCAPED_UNICODE) : null,
            'auditable_id' => $model->getKey(),
            'auditable_type' => get_class($model),
            'ip' => Request::ip(),
            'user_agent' => substr(Request::userAgent() ?? '', 0, 500),
            'url' => substr(Request::fullUrl() ?? '', 0, 500),
            'codigo_respuesta' => null,
            'created_at' => now(),
        ];

        try {
            DB::table('auditoria')->insert($payload);
        } catch (\Throwable $e) {
            // La auditoría no debe romper la operación principal.
        }
    }

    protected static function filterSensitive(?array $data): ?array
    {
        if ($data === null) {
            return null;
        }

        $sensitive = [
            'password',
            'token',
            'secret',
            'api_key',
            'credit_card',
            'pin_rapido',
            'secret_2fa',
            'token_recuperacion',
        ];

        return collect($data)->map(function ($value, $key) use ($sensitive) {
            foreach ($sensitive as $word) {
                if (stripos($key, $word) !== false) {
                    return '***REDACTED***';
                }
            }

            if (is_array($value)) {
                return static::filterSensitive($value);
            }

            return $value;
        })->all();
    }

    public function getAuditableIgnored(): array
    {
        return property_exists($this, 'auditableIgnored')
            ? $this->auditableIgnored
            : ['created_at', 'updated_at', 'email_verified_at'];
    }

    public function getAuditDescription(string $event): string
    {
        $name = class_basename($this);
        $id = $this->getKey();

        $trans = [
            'created' => 'Creó',
            'updated' => 'Modificó',
            'deleted' => 'Eliminó',
        ];

        $action = $trans[$event] ?? $event;

        return "{$action} {$name} #{$id}";
    }
}