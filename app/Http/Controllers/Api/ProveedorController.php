<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProveedorController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('proveedores');
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('nombre', 'like', "%{$request->q}%")
                  ->orWhere('empresa', 'like', "%{$request->q}%")
                  ->orWhere('email', 'like', "%{$request->q}%");
            });
        }
        if ($request->has('activo')) $query->where('activo', $request->activo);
        $data = $query->orderBy('nombre')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['nombre' => 'required|string']);
        $id = DB::table('proveedores')->insertGetId([
            'nombre' => $request->nombre, 'contacto_nombre' => $request->contacto_nombre,
            'empresa' => $request->empresa, 'telefono' => $request->telefono,
            'email' => $request->email, 'direccion' => $request->direccion,
            'notas' => $request->notas, 'calificacion' => $request->calificacion,
            'activo' => true, 'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    public function show($id)
    {
        $prov = DB::table('proveedores')->where('id', $id)->first();
        if (!$prov) return response()->json(['error' => 'No encontrado'], 404);
        $prov->compras = DB::table('compras')->where('proveedor_id', $id)->orderByDesc('created_at')->limit(10)->get();
        $prov->total_compras = DB::table('compras')->where('proveedor_id', $id)->where('estado', 'recibida')->sum('total');
        return response()->json(['proveedor' => $prov]);
    }

    public function update(Request $request, $id)
    {
        DB::table('proveedores')->where('id', $id)->update(array_filter([
            'nombre' => $request->nombre, 'contacto_nombre' => $request->contacto_nombre,
            'empresa' => $request->empresa, 'telefono' => $request->telefono,
            'email' => $request->email, 'direccion' => $request->direccion,
            'notas' => $request->notas, 'calificacion' => $request->calificacion,
            'activo' => $request->activo, 'updated_at' => now(),
        ], fn($v) => $v !== null));
        return response()->json(['success' => true]);
    }

    public function buscar(Request $request)
    {
        $provs = DB::table('proveedores')
            ->where('activo', 1)
            ->where('nombre', 'like', "%{$request->q}%")
            ->select('id', 'nombre', 'empresa', 'telefono')
            ->limit(20)->get();
        return response()->json(['proveedores' => $provs]);
    }
}
