<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EtiquetaController extends Controller
{
    public function index()
    {
        $etiquetas = DB::table('etiquetas')->orderBy('nombre')->get();
        foreach ($etiquetas as &$e) {
            $e->productos_count = DB::table('productos')
                ->whereRaw("JSON_CONTAINS(COALESCE(productos.descripcion, '[]'), ?)", ['"' . $e->nombre . '"'])
                ->count();
            $e->clientes_count = DB::table('cliente_etiquetas')->where('etiqueta_id', $e->id)->count();
        }
        return response()->json(['etiquetas' => $etiquetas]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100|unique:etiquetas,nombre',
            'color' => 'nullable|string|max:7',
        ]);
        $id = DB::table('etiquetas')->insertGetId([
            'nombre' => $request->nombre,
            'color' => $request->color ?? '#3b82f6',
            'created_at' => now(),
        ]);
        return response()->json(['success' => true, 'etiqueta' => DB::table('etiquetas')->find($id)]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nombre' => 'required|string|max:100',
            'color' => 'nullable|string|max:7',
        ]);
        DB::table('etiquetas')->where('id', $id)->update([
            'nombre' => $request->nombre,
            'color' => $request->color,
        ]);
        return response()->json(['success' => true]);
    }

    public function destroy($id)
    {
        DB::table('cliente_etiquetas')->where('etiqueta_id', $id)->delete();
        DB::table('etiquetas')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }
}
