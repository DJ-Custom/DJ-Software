<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ListaPreciosController extends Controller
{
    public function index()
    {
        $listas = DB::table('listas_precios')
            ->select('listas_precios.*')
            ->selectRaw('(SELECT COUNT(*) FROM lista_precios_productos WHERE lista_precios_productos.lista_id = listas_precios.id) as productos_count')
            ->selectRaw('(SELECT COUNT(*) FROM lista_precios_clientes WHERE lista_precios_clientes.lista_id = listas_precios.id) as clientes_count')
            ->orderBy('nombre')
            ->get();
        return response()->json(['listas' => $listas]);
    }

    public function store(Request $request)
    {
        $request->validate(['nombre' => 'required|string|max:100']);
        $id = DB::table('listas_precios')->insertGetId([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'descuento_porcentaje' => $request->descuento_porcentaje ?? 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        if ($request->clientes && is_array($request->clientes)) {
            foreach ($request->clientes as $clienteId) {
                DB::table('lista_precios_clientes')->insertOrIgnore([
                    'lista_id' => $id, 'cliente_id' => $clienteId, 'created_at' => now(),
                ]);
            }
        }
        if ($request->productos && is_array($request->productos)) {
            foreach ($request->productos as $prod) {
                DB::table('lista_precios_productos')->insertOrIgnore([
                    'lista_id' => $id, 'producto_id' => $prod['producto_id'],
                    'precio_especial' => $prod['precio_especial'], 'created_at' => now(),
                ]);
            }
        }

        return response()->json(['success' => true, 'id' => $id]);
    }

    public function update(Request $request, $id)
    {
        $request->validate(['nombre' => 'required|string|max:100']);
        DB::table('listas_precios')->where('id', $id)->update([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'descuento_porcentaje' => $request->descuento_porcentaje ?? 0,
            'updated_at' => now(),
        ]);

        if ($request->has('clientes') && is_array($request->clientes)) {
            DB::table('lista_precios_clientes')->where('lista_id', $id)->delete();
            foreach ($request->clientes as $clienteId) {
                DB::table('lista_precios_clientes')->insertOrIgnore([
                    'lista_id' => $id, 'cliente_id' => $clienteId, 'created_at' => now(),
                ]);
            }
        }
        if ($request->has('productos') && is_array($request->productos)) {
            DB::table('lista_precios_productos')->where('lista_id', $id)->delete();
            foreach ($request->productos as $prod) {
                DB::table('lista_precios_productos')->insertOrIgnore([
                    'lista_id' => $id, 'producto_id' => $prod['producto_id'],
                    'precio_especial' => $prod['precio_especial'], 'created_at' => now(),
                ]);
            }
        }

        return response()->json(['success' => true]);
    }

    public function detalle($id)
    {
        $clientes = DB::table('lista_precios_clientes as lpc')
            ->join('clientes as c', 'lpc.cliente_id', '=', 'c.id')
            ->where('lpc.lista_id', $id)
            ->select('c.id', 'c.nombre', 'c.email')
            ->get();

        $productos = DB::table('lista_precios_productos as lpp')
            ->join('productos as p', 'lpp.producto_id', '=', 'p.id')
            ->where('lpp.lista_id', $id)
            ->select('p.id', 'p.nombre as producto_nombre', 'lpp.precio_especial')
            ->get();

        return response()->json(['clientes' => $clientes, 'productos' => $productos]);
    }

    public function asignarCliente(Request $request, $id)
    {
        $request->validate(['cliente_id' => 'required|integer']);
        $exists = DB::table('lista_precios_clientes')
            ->where('lista_id', $id)->where('cliente_id', $request->cliente_id)->exists();
        if ($exists) return response()->json(['error' => 'Cliente ya asignado'], 422);

        DB::table('lista_precios_clientes')->insert([
            'lista_id' => $id,
            'cliente_id' => $request->cliente_id,
            'created_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function quitarCliente($id, $clienteId)
    {
        DB::table('lista_precios_clientes')->where('lista_id', $id)->where('cliente_id', $clienteId)->delete();
        return response()->json(['success' => true]);
    }

    public function agregarProducto(Request $request, $id)
    {
        $request->validate(['producto_id' => 'required|integer', 'precio_especial' => 'required|numeric|min:0']);
        $exists = DB::table('lista_precios_productos')
            ->where('lista_id', $id)->where('producto_id', $request->producto_id)->exists();
        if ($exists) return response()->json(['error' => 'Producto ya existe en la lista'], 422);

        DB::table('lista_precios_productos')->insert([
            'lista_id' => $id,
            'producto_id' => $request->producto_id,
            'precio_especial' => $request->precio_especial,
            'created_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function actualizarProducto(Request $request, $id, $productoId)
    {
        $request->validate(['precio_especial' => 'required|numeric|min:0']);
        DB::table('lista_precios_productos')
            ->where('lista_id', $id)->where('producto_id', $productoId)
            ->update(['precio_especial' => $request->precio_especial]);
        return response()->json(['success' => true]);
    }

    public function quitarProducto($id, $productoId)
    {
        DB::table('lista_precios_productos')->where('lista_id', $id)->where('producto_id', $productoId)->delete();
        return response()->json(['success' => true]);
    }

    /**
     * Get price list products for a specific client.
     * Returns array of producto_id => precio_especial
     */
    public function preciosCliente(Request $request)
    {
        $clienteId = $request->get('cliente_id');
        if (!$clienteId) return response()->json(['precios' => []]);

        $listaIds = DB::table('lista_precios_clientes')
            ->where('cliente_id', $clienteId)
            ->pluck('lista_id');

        if ($listaIds->isEmpty()) return response()->json(['precios' => []]);

        $precios = DB::table('lista_precios_productos')
            ->whereIn('lista_id', $listaIds)
            ->select('producto_id', 'precio_especial')
            ->get()
            ->keyBy('producto_id')
            ->map(fn($p) => (float) $p->precio_especial);

        $descuento = DB::table('listas_precios')
            ->whereIn('id', $listaIds)
            ->max('descuento_porcentaje') ?? 0;

        return response()->json([
            'precios' => $precios,
            'descuento_global' => (float) $descuento,
        ]);
    }
}
