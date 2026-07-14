<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CuentasCobrarController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('cuentas_cobrar as cc')
            ->leftJoin('clientes as cl', 'cc.cliente_id', '=', 'cl.id')
            ->leftJoin('ventas as v', 'cc.venta_id', '=', 'v.id')
            ->select('cc.*', 'cl.nombre as cliente_nombre', 'v.numero_factura');

        if ($request->filled('estado')) {
            $query->where('cc.estado', $request->estado);
        }

        $cuentas = $query->orderByDesc('cc.created_at')->get()->map(function ($c) {
            $c->vencido = $c->fecha_vencimiento && $c->fecha_vencimiento < now()->toDateString() && $c->estado !== 'pagada';
            return $c;
        });

        return response()->json(['cuentas' => $cuentas]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'cliente_id' => 'required|exists:clientes,id',
            'monto_total' => 'required|numeric|min:0.01',
            'fecha_vencimiento' => 'nullable|date',
        ]);

        $id = DB::table('cuentas_cobrar')->insertGetId([
            'cliente_id' => $request->cliente_id,
            'venta_id' => $request->venta_id,
            'monto_total' => $request->monto_total,
            'monto_pagado' => 0,
            'saldo_pendiente' => $request->monto_total,
            'fecha_vencimiento' => $request->fecha_vencimiento,
            'estado' => 'pendiente',
            'notas' => $request->notas,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'cuenta' => DB::table('cuentas_cobrar')->find($id)]);
    }

    public function update(Request $request, $id)
    {
        $cuenta = DB::table('cuentas_cobrar')->where('id', $id)->first();
        if (!$cuenta) return response()->json(['error' => 'Cuenta no encontrada'], 404);

        $request->validate([
            'monto_total' => 'sometimes|numeric|min:0.01',
            'fecha_vencimiento' => 'nullable|date',
        ]);

        DB::table('cuentas_cobrar')->where('id', $id)->update([
            'monto_total' => $request->monto_total ?? $cuenta->monto_total,
            'fecha_vencimiento' => $request->fecha_vencimiento ?? $cuenta->fecha_vencimiento,
            'notas' => $request->notas ?? $cuenta->notas,
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'cuenta' => DB::table('cuentas_cobrar')->find($id)]);
    }

    public function destroy($id)
    {
        $cuenta = DB::table('cuentas_cobrar')->where('id', $id)->first();
        if (!$cuenta) return response()->json(['error' => 'Cuenta no encontrada'], 404);

        DB::table('cuentas_cobrar')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }

    public function registrarPago(Request $request, $id)
    {
        $cuenta = DB::table('cuentas_cobrar')->where('id', $id)->first();
        if (!$cuenta) return response()->json(['error' => 'Cuenta no encontrada'], 404);

        $request->validate([
            'monto' => 'required|numeric|min:0.01',
            'metodo_pago' => 'nullable|string',
            'referencia' => 'nullable|string',
        ]);

        $montoPagado = (float) $cuenta->monto_pagado + (float) $request->monto;
        $saldoPendiente = max(0, (float) $cuenta->monto_total - $montoPagado);
        $nuevoEstado = $saldoPendiente <= 0 ? 'pagada' : 'pendiente';

        DB::table('cuentas_cobrar')->where('id', $id)->update([
            'monto_pagado' => $montoPagado,
            'saldo_pendiente' => $saldoPendiente,
            'estado' => $nuevoEstado,
            'updated_at' => now(),
        ]);

        DB::table('cuentas_cobrar_pagos')->insert([
            'cuenta_id' => $id,
            'monto' => $request->monto,
            'metodo_pago' => $request->metodo_pago ?? 'efectivo',
            'referencia' => $request->referencia,
            'usuario_id' => auth()->id(),
            'created_at' => now(),
        ]);

        return response()->json(['success' => true]);
    }
}
