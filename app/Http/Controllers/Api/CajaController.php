<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CajaController extends Controller
{
    public function stats()
    {
        $sesionesAbiertas = DB::table('caja_sesiones')->where('estado', 'abierta')->count();
        $ventasHoy = DB::table('ventas')->whereDate('created_at', today())->where('estado', 'completada')
            ->selectRaw('COALESCE(SUM(total),0) as total, COUNT(*) as count')->first();
        $efectivoHoy = DB::table('ventas')->whereDate('created_at', today())->where('estado', 'completada')
            ->sum('monto_efectivo');
        $retirosHoy = DB::table('caja_retiros')->whereDate('created_at', today())->sum('monto');

        return response()->json([
            'sesiones_abiertas' => $sesionesAbiertas,
            'ventas_hoy' => (float)$ventasHoy->total,
            'num_ventas' => (int)$ventasHoy->count,
            'efectivo_hoy' => (float)$efectivoHoy,
            'retiros_hoy' => (float)$retirosHoy,
        ]);
    }

    public function cajas()
    {
        $cajas = DB::table('cajas as c')
            ->leftJoin('ubicaciones as u', 'c.ubicacion_id', '=', 'u.id')
            ->leftJoin('usuarios as us', 'c.usuario_id', '=', 'us.id')
            ->where('c.activo', 1)
            ->select('c.*', 'u.nombre as ubicacion_nombre', 'us.nombre as usuario_asignado_nombre')
            ->orderBy('c.nombre')
            ->get()
            ->map(function ($caja) {
                $sesion = DB::table('caja_sesiones as cs')
                    ->join('usuarios as us', 'cs.usuario_id', '=', 'us.id')
                    ->where('cs.caja_id', $caja->id)->where('cs.estado', 'abierta')
                    ->select('cs.id as sesion_id', 'us.nombre as cajero_actual')
                    ->first();
                $caja->sesion_abierta_id = $sesion->sesion_id ?? null;
                $caja->cajero_actual = $sesion->cajero_actual ?? null;
                return $caja;
            });

        return response()->json(['cajas' => $cajas]);
    }

    public function sesionActiva(Request $request)
    {
        $userId = $request->user()->id;
        $sesion = DB::table('caja_sesiones as cs')
            ->join('cajas as c', 'cs.caja_id', '=', 'c.id')
            ->join('usuarios as u', 'cs.usuario_id', '=', 'u.id')
            ->leftJoin('usuarios as ua', 'c.usuario_id', '=', 'ua.id')
            ->where('cs.usuario_id', $userId)->where('cs.estado', 'abierta')
            ->select('cs.*', 'c.nombre as caja_nombre', 'u.nombre as cajero_nombre', 'ua.id as usuario_asignado_id', 'ua.nombre as usuario_asignado_nombre')
            ->first();

        if ($sesion) {
            $ventasUsuario = $sesion->usuario_asignado_id ?: $userId;
            $ventas = DB::table('ventas')
                ->where('usuario_id', $ventasUsuario)->where('estado', 'completada')
                ->where('created_at', '>=', $sesion->apertura_at)
                ->selectRaw('COUNT(*) as num, COALESCE(SUM(total),0) as total, COALESCE(SUM(monto_efectivo),0) as efectivo, COALESCE(SUM(monto_tarjeta),0) as tarjeta, COALESCE(SUM(monto_sinpe),0) as sinpe')
                ->first();
            $retiros = DB::table('caja_retiros')->where('sesion_id', $sesion->id)->sum('monto');
            $devoluciones = DB::table('devoluciones')
                ->where('usuario_id', $ventasUsuario)->where('estado', 'completada')
                ->where('created_at', '>=', $sesion->apertura_at)->sum('monto_total');

            $sesion->total_ventas = (float)$ventas->total;
            $sesion->total_efectivo = (float)$ventas->efectivo;
            $sesion->total_tarjeta = (float)$ventas->tarjeta;
            $sesion->total_sinpe = (float)$ventas->sinpe;
            $sesion->num_ventas = (int)$ventas->num;
            $sesion->total_retiros = (float)$retiros;
            $sesion->total_devoluciones = (float)$devoluciones;
            $sesion->efectivo_en_caja = (float)$sesion->monto_apertura + (float)$ventas->efectivo - (float)$retiros - (float)$devoluciones;
        }

        return response()->json(['sesion' => $sesion]);
    }

    public function abrir(Request $request)
    {
        $validated = $request->validate([
            'caja_id' => 'required|exists:cajas,id',
            'monto_apertura' => 'required|numeric|min:0',
        ]);

        $lockKey = $this->generateLockKey('abrir_caja', ['caja_id' => $request->caja_id]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $yaAbierta = DB::table('caja_sesiones')
                ->where('caja_id', $request->caja_id)->where('estado', 'abierta')->exists();
            if ($yaAbierta) return response()->json(['error' => 'Esta caja ya tiene una sesión abierta'], 400);

            $id = DB::table('caja_sesiones')->insertGetId([
                'caja_id' => $request->caja_id,
                'usuario_id' => $request->user()->id,
                'monto_apertura' => $request->monto_apertura,
                'estado' => 'abierta',
                'apertura_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json(['success' => true, 'sesion_id' => $id, 'message' => 'Caja abierta']);
        }, response()->json(['error' => 'Ya se está abriendo esta caja. Por favor espere.'], 429));
    }

    public function cerrar(Request $request)
    {
        $validated = $request->validate([
            'sesion_id' => 'required',
            'monto_cierre' => 'required|numeric|min:0',
        ]);

        $lockKey = $this->generateLockKey('cerrar_caja', ['sesion_id' => $request->sesion_id]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $sesion = DB::table('caja_sesiones')->where('id', $request->sesion_id)->where('estado', 'abierta')->first();
            if (!$sesion) return response()->json(['error' => 'Sesión no encontrada o ya está cerrada'], 404);

            $cajaUsuario = DB::table('cajas')->where('id', $sesion->caja_id)->value('usuario_id');
            $ventasUsuario = $cajaUsuario ?: $sesion->usuario_id;
            $ventas = DB::table('ventas')
                ->where('usuario_id', $ventasUsuario)->where('estado', 'completada')
                ->where('created_at', '>=', $sesion->apertura_at)->sum('monto_efectivo');
            $retiros = DB::table('caja_retiros')->where('sesion_id', $sesion->id)->sum('monto');
            $esperado = (float)$sesion->monto_apertura + (float)$ventas - (float)$retiros;

            DB::table('caja_sesiones')->where('id', $request->sesion_id)->update([
                'monto_cierre' => $request->monto_cierre,
                'monto_esperado' => $esperado,
                'diferencia' => $request->monto_cierre - $esperado,
                'estado' => 'cerrada',
                'cierre_at' => now(),
                'notas_cierre' => $request->notas_cierre ?? null,
                'updated_at' => now(),
            ]);

            return response()->json(['success' => true, 'message' => 'Caja cerrada']);
        }, response()->json(['error' => 'Ya se está cerrando esta caja. Por favor espere.'], 429));
    }

    public function retiro(Request $request)
    {
        $validated = $request->validate([
            'sesion_id' => 'required',
            'monto' => 'required|numeric|min:0.01',
            'motivo' => 'required|string',
        ]);

        $lockKey = $this->generateLockKey('retiro_caja', [
            'sesion_id' => $request->sesion_id,
            'monto' => $request->monto,
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            DB::table('caja_retiros')->insert([
                'sesion_id' => $request->sesion_id,
                'usuario_id' => $request->user()->id,
                'monto' => $request->monto,
                'motivo' => $request->motivo,
                'notas' => $request->notas,
                'created_at' => now(),
            ]);

            return response()->json(['success' => true, 'message' => 'Retiro registrado']);
        }, response()->json(['error' => 'Ya se está procesando este retiro. Por favor espere.'], 429));
    }

    public function historial(Request $request)
    {
        $sesiones = DB::table('caja_sesiones as cs')
            ->join('cajas as c', 'cs.caja_id', '=', 'c.id')
            ->join('usuarios as u', 'cs.usuario_id', '=', 'u.id')
            ->select('cs.*', 'c.nombre as caja_nombre', 'u.nombre as cajero_nombre')
            ->orderByDesc('cs.created_at')
            ->paginate(20);

        return response()->json($sesiones);
    }
}
