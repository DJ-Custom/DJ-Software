<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AuditLog
{
    public function handle(Request $request, Closure $next)
    {
        $inicio = now();

        $response = $next($request);

        if (!config('app.audit_enabled', true)) {
            return $response;
        }

        $metodosAuditables = ['POST', 'PUT', 'PATCH', 'DELETE'];

        if (!in_array($request->method(), $metodosAuditables)) {
            return $response;
        }

        try {
            DB::table('auditoria')
                ->where('usuario_id', Auth::id())
                ->where('ip', $request->ip())
                ->where('url', substr($request->fullUrl(), 0, 500))
                ->whereNull('codigo_respuesta')
                ->where('created_at', '>=', $inicio->subSeconds(2))
                ->update([
                    'codigo_respuesta' => $response->getStatusCode(),
                ]);
        } catch (\Throwable $e) {
            \Log::error('Error al registrar auditoría: ' . $e->getMessage());
        }

        return $response;
    }
}