<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ComboController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('combos');
        if ($request->has('activo')) $query->where('activo', $request->activo);
        $combos = $query->orderByDesc('created_at')->get();

        foreach ($combos as $combo) {
            $combo->productos = DB::table('combo_productos as cp')
                ->join('productos as p', 'cp.producto_id', '=', 'p.id')
                ->where('cp.combo_id', $combo->id)
                ->select('p.nombre', 'cp.cantidad')
                ->get();
        }

        return response()->json(['combos' => $combos]);
    }

    public function store(Request $request)
    {
        $request->validate(['nombre' => 'required', 'precio_combo' => 'required|numeric', 'productos' => 'required|array']);

        $id = DB::table('combos')->insertGetId([
            'nombre' => $request->nombre, 'descripcion' => $request->descripcion,
            'precio_combo' => $request->precio_combo, 'precio_regular' => $request->precio_regular ?? 0,
            'fecha_inicio' => $request->fecha_inicio, 'fecha_fin' => $request->fecha_fin,
            'activo' => true, 'created_at' => now(), 'updated_at' => now(),
        ]);

        foreach ($request->productos as $prod) {
            DB::table('combo_productos')->insert([
                'combo_id' => $id, 'producto_id' => $prod['producto_id'], 'cantidad' => $prod['cantidad'] ?? 1,
            ]);
        }

        return response()->json(['success' => true, 'id' => $id]);
    }

    public function show($id)
    {
        $combo = DB::table('combos')->where('id', $id)->first();
        if (!$combo) return response()->json(['error' => 'No encontrado'], 404);
        $combo->productos = DB::table('combo_productos as cp')
            ->join('productos as p', 'cp.producto_id', '=', 'p.id')
            ->where('cp.combo_id', $id)
            ->select('cp.*', 'p.nombre as producto_nombre', 'p.precio_venta')
            ->get();
        return response()->json(['combo' => $combo]);
    }

    public function toggle($id)
    {
        $combo = DB::table('combos')->where('id', $id)->first();
        DB::table('combos')->where('id', $id)->update(['activo' => !$combo->activo, 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }

    // === CUPONES ===
    public function cupones(Request $request)
    {
        $cupones = DB::table('cupones')->orderByDesc('created_at')->get();
        return response()->json(['cupones' => $cupones]);
    }

    public function crearCupon(Request $request)
    {
        $request->validate(['codigo' => 'required|unique:cupones,codigo', 'tipo_descuento' => 'required', 'valor_descuento' => 'required|numeric']);

        $id = DB::table('cupones')->insertGetId([
            'codigo' => strtoupper($request->codigo),
            'tipo_descuento' => $request->tipo_descuento,
            'valor_descuento' => $request->valor_descuento,
            'compra_minima' => $request->compra_minima ?? 0,
            'usos_maximos' => $request->usos_maximos,
            'fecha_inicio' => $request->fecha_inicio,
            'fecha_fin' => $request->fecha_fin,
            'activo' => true,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'id' => $id]);
    }

    public function toggleCupon($id)
    {
        $cupon = DB::table('cupones')->where('id', $id)->first();
        DB::table('cupones')->where('id', $id)->update(['activo' => !$cupon->activo, 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }

    // === PROMOCIONES ===
    public function promociones()
    {
        $promos = DB::table('promociones')->orderByDesc('created_at')->get();
        return response()->json(['promociones' => $promos]);
    }

    public function crearPromocion(Request $request)
    {
        $request->validate(['nombre' => 'required', 'tipo_descuento' => 'required', 'valor_descuento' => 'required|numeric']);

        $id = DB::table('promociones')->insertGetId([
            'nombre' => $request->nombre, 'descripcion' => $request->descripcion,
            'tipo_descuento' => $request->tipo_descuento, 'valor_descuento' => $request->valor_descuento,
            'aplica_a' => $request->aplica_a ?? 'todos', 'aplica_id' => $request->aplica_id,
            'compra_minima' => $request->compra_minima ?? 0,
            'fecha_inicio' => $request->fecha_inicio, 'fecha_fin' => $request->fecha_fin,
            'activo' => true, 'created_at' => now(), 'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'id' => $id]);
    }

    public function togglePromocion($id)
    {
        $promo = DB::table('promociones')->where('id', $id)->first();
        DB::table('promociones')->where('id', $id)->update(['activo' => !$promo->activo, 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }
}
