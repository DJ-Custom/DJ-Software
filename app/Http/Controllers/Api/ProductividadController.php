<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProductividadController extends Controller
{
    public function index(Request $request)
    {
        $desde = $request->get('desde', now()->startOfMonth()->toDateString());
        $hasta = $request->get('hasta', now()->toDateString());
        $hoy = now()->startOfDay()->toDateString();

        $usuarios = DB::table('usuarios')
            ->where('activo', 1)
            ->select('id', 'nombre', 'email')
            ->get()
            ->map(function ($u) use ($desde, $hasta, $hoy) {
                $resumen = DB::table('productividad_resumen')
                    ->where('usuario_id', $u->id)
                    ->where('fecha', '>=', $desde)
                    ->where('fecha', '<=', $hasta)
                    ->where('periodo', 'dia')
                    ->selectRaw('COALESCE(SUM(total_minutos), 0) as total_minutos, COALESCE(SUM(total_sesiones), 0) as total_sesiones, COALESCE(SUM(ventas_generadas), 0) as ventas_generadas, COALESCE(SUM(cantidad_ventas), 0) as cantidad_ventas')
                    ->first();

                $totalMin = (int) ($resumen?->total_minutos ?? 0);
                $totalSesiones = (int) ($resumen?->total_sesiones ?? 0);
                $ventasGeneradas = (float) ($resumen?->ventas_generadas ?? 0);
                $cantidadVentas = (int) ($resumen?->cantidad_ventas ?? 0);

                $sesionActiva = DB::table('productividad_sesiones')
                    ->where('usuario_id', $u->id)
                    ->whereNull('fin_sesion')
                    ->orderByDesc('inicio_sesion')
                    ->first();

                $sesionActivaInicio = null;
                $ultimaActividad = null;
                $enLinea = false;
                $enPausa = false;

                if ($sesionActiva) {
                    $sesionActivaInicio = $sesionActiva->inicio_sesion;
                    $ultimaActividad = $sesionActiva->ultima_actividad ?? $sesionActiva->inicio_sesion;
                    $enPausa = (bool) $sesionActiva->en_pausa;

                    $ultimaTs = \Carbon\Carbon::parse($ultimaActividad);
                    $sesionReciente = $ultimaTs->diffInMinutes(now()) < 5;
                    $enLinea = $sesionReciente;

                    if (!$sesionReciente) {
                        $this->cerrarSesionInterna($sesionActiva, now());
                        $this->actualizarResumen($u->id, $sesionActiva);
                        $sesionActiva = null;
                        $enLinea = false;
                        $sesionActivaInicio = null;
                        $ultimaActividad = null;
                    } else {
                        $tiempoActivoSeg = (int) ($sesionActiva->tiempo_activo ?? 0);

                        $minHoy = (int) ceil($tiempoActivoSeg / 60);
                        $totalMin += $minHoy;
                    }
                }

                $u->total_minutos = $totalMin;
                $u->total_horas = floor($totalMin / 60);
                $u->total_minutos_resto = $totalMin % 60;
                $u->total_sesiones = $totalSesiones;
                $u->ventas_generadas = $ventasGeneradas;
                $u->cantidad_ventas = $cantidadVentas;
                $u->promedio_por_sesion = $u->total_sesiones > 0
                    ? round($u->ventas_generadas / $u->total_sesiones, 2)
                    : 0;
                $u->sesion_activa_inicio = $sesionActivaInicio;
                $u->ultima_actividad = $ultimaActividad;
                $u->en_linea = $enLinea;
                $u->en_pausa = $enPausa;

                return $u;
            });

        return response()->json([
            'usuarios' => $usuarios,
            'desde' => $desde,
            'hasta' => $hasta,
        ]);
    }

    public function registrarSesion(Request $request)
    {
        $userId = auth()->id();
        $ahora = now();
        $tabId = $request->get('tab_id');

        $stales = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->get();

        foreach ($stales as $sesion) {
            $this->cerrarSesionInterna($sesion, $ahora);
            $this->actualizarResumen($userId, $sesion);
        }

        $id = DB::table('productividad_sesiones')->insertGetId([
            'usuario_id' => $userId,
            'inicio_sesion' => $ahora,
            'ultima_actividad' => $ahora,
            'tiempo_activo' => 0,
            'en_pausa' => false,
            'tab_id' => $tabId,
            'ip' => $request->ip(),
            'user_agent' => substr($request->userAgent() ?? '', 0, 500),
        ]);

        return response()->json(['sesion_id' => $id]);
    }

    public function sync(Request $request)
    {
        $userId = auth()->id();
        $ahora = now();
        $activeSeconds = $request->get('active_seconds', 0);
        $tabId = $request->get('tab_id');

        $sesion = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->orderByDesc('inicio_sesion')
            ->first();

        if (!$sesion) {
            $id = DB::table('productividad_sesiones')->insertGetId([
                'usuario_id' => $userId,
                'inicio_sesion' => $ahora,
                'ultima_actividad' => $ahora,
                'tiempo_activo' => max(0, (int) $activeSeconds),
                'en_pausa' => false,
                'tab_id' => $tabId,
                'ip' => $request->ip(),
                'user_agent' => substr($request->userAgent() ?? '', 0, 500),
            ]);
            return response()->json(['sesion_id' => $id, 'nueva' => true]);
        }

        $validated = max(0, (int) $activeSeconds);
        $currentActive = (int) ($sesion->tiempo_activo ?? 0);

        if ($validated >= $currentActive) {
            DB::table('productividad_sesiones')
                ->where('id', $sesion->id)
                ->update([
                    'tiempo_activo' => $validated,
                    'ultima_actividad' => $ahora,
                    'en_pausa' => false,
                ]);
        } else {
            DB::table('productividad_sesiones')
                ->where('id', $sesion->id)
                ->update([
                    'ultima_actividad' => $ahora,
                ]);
        }

        return response()->json(['ok' => true]);
    }

    public function pause(Request $request)
    {
        $userId = auth()->id();
        $ahora = now();
        $activeSeconds = $request->get('active_seconds', 0);

        $sesion = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->orderByDesc('inicio_sesion')
            ->first();

        if (!$sesion) {
            return response()->json(['error' => 'No active session'], 404);
        }

        $validated = max(0, (int) $activeSeconds);
        $currentActive = (int) ($sesion->tiempo_activo ?? 0);
        $newActive = max($validated, $currentActive);

        DB::table('productividad_sesiones')
            ->where('id', $sesion->id)
            ->update([
                'tiempo_activo' => $newActive,
                'ultima_actividad' => $ahora,
                'en_pausa' => true,
            ]);

        return response()->json(['ok' => true, 'tiempo_activo' => $newActive]);
    }

    public function resume(Request $request)
    {
        $userId = auth()->id();
        $ahora = now();

        $sesion = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->orderByDesc('inicio_sesion')
            ->first();

        if (!$sesion) {
            $id = DB::table('productividad_sesiones')->insertGetId([
                'usuario_id' => $userId,
                'inicio_sesion' => $ahora,
                'ultima_actividad' => $ahora,
                'tiempo_activo' => 0,
                'en_pausa' => false,
                'tab_id' => $request->get('tab_id'),
                'ip' => $request->ip(),
                'user_agent' => substr($request->userAgent() ?? '', 0, 500),
            ]);
            return response()->json(['sesion_id' => $id, 'nueva' => true]);
        }

        DB::table('productividad_sesiones')
            ->where('id', $sesion->id)
            ->update([
                'ultima_actividad' => $ahora,
                'en_pausa' => false,
            ]);

        return response()->json(['ok' => true]);
    }

    public function heartbeat()
    {
        $userId = auth()->id();
        $ahora = now();

        $updated = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->update([
                'ultima_actividad' => $ahora,
                'en_pausa' => false,
            ]);

        if (!$updated) {
            $id = DB::table('productividad_sesiones')->insertGetId([
                'usuario_id' => $userId,
                'inicio_sesion' => $ahora,
                'ultima_actividad' => $ahora,
                'tiempo_activo' => 0,
                'en_pausa' => false,
                'ip' => request()->ip(),
                'user_agent' => substr(request()->userAgent() ?? '', 0, 500),
            ]);
            return response()->json(['sesion_id' => $id, 'nueva' => true]);
        }

        return response()->json(['ok' => true]);
    }

    public function cerrarSesion(Request $request)
    {
        $userId = auth()->id();
        $ahora = now();

        $activas = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->get();

        foreach ($activas as $sesion) {
            $this->cerrarSesionInterna($sesion, $ahora);
            $this->actualizarResumen($userId, $sesion);
        }

        return response()->json(['success' => true]);
    }

    private function cerrarSesionInterna($sesion, $ahora): void
    {
        $tiempoActivo = (int) ($sesion->tiempo_activo ?? 0);
        $enPausa = (bool) ($sesion->en_pausa ?? false);

        if (!$enPausa && $sesion->ultima_actividad) {
            $ultimaTs = \Carbon\Carbon::parse($sesion->ultima_actividad);
            $diff = (int) $ultimaTs->diffInSeconds($ahora);
            if ($diff > 0 && $diff <= 300) {
                $tiempoActivo += $diff;
            }
        }

        $minutos = (int) ceil($tiempoActivo / 60);

        DB::table('productividad_sesiones')->where('id', $sesion->id)->update([
            'fin_sesion' => $ahora,
            'duracion_minutos' => $minutos,
            'tiempo_activo' => $tiempoActivo,
            'en_pausa' => true,
        ]);

        $sesion->duracion_minutos = $minutos;
        $sesion->tiempo_activo = $tiempoActivo;
        $sesion->en_pausa = true;
    }

    private function actualizarResumen(int $userId, $sesion): void
    {
        $fecha = \Carbon\Carbon::parse($sesion->inicio_sesion)->toDateString();
        $minutos = (int) ($sesion->duracion_minutos ?? 0);

        if ($minutos <= 0) {
            $minutos = (int) ceil(((int) ($sesion->tiempo_activo ?? 0)) / 60);
        }

        if ($minutos <= 0) {
            return;
        }

        $ventas = DB::table('ventas')
            ->where('usuario_id', $userId)
            ->where('created_at', '>=', $sesion->inicio_sesion)
            ->where('estado', '!=', 'cancelada')
            ->selectRaw('COALESCE(SUM(total), 0) as total_ventas, COUNT(*) as cantidad')
            ->first();

        $ventasTotal = $ventas->total_ventas ?? 0;
        $ventasCount = $ventas->cantidad ?? 0;

        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $fecha, 'periodo' => 'dia'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        $semanaInicio = \Carbon\Carbon::parse($fecha)->startOfWeek()->toDateString();
        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $semanaInicio, 'periodo' => 'semana'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        $mesInicio = \Carbon\Carbon::parse($fecha)->startOfMonth()->toDateString();
        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $mesInicio, 'periodo' => 'mes'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => '1970-01-01', 'periodo' => 'historico'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );
    }
}
