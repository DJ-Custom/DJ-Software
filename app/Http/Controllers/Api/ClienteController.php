<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\ClienteNota;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ClienteController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->get('page', 1));
        $limit = min(100, max(1, (int) $request->get('limit', $request->get('per_page', 24))));

        $query = Cliente::query();

        if ($request->filled('cliente_categoria_id')) {
            $query->where('cliente_categoria_id', $request->cliente_categoria_id);
        }
        if ($request->filled('activo')) {
            $query->where('activo', $request->activo);
        }
        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($qb) use ($q) {
                $qb->where('nombre', 'LIKE', "%{$q}%")
                    ->orWhere('telefono', 'LIKE', "%{$q}%")
                    ->orWhere('cedula', 'LIKE', "%{$q}%")
                    ->orWhere('email', 'LIKE', "%{$q}%");
            });
        }
        if ($request->filled('etiqueta_ids')) {
            $etiquetaIds = (array) $request->input('etiqueta_ids');
            $query->whereHas('etiquetas', function ($qb) use ($etiquetaIds) {
                $qb->whereIn('etiquetas.id', $etiquetaIds);
            });
        }
        if ($request->filled('con_email')) {
            $query->whereNotNull('email')->where('email', '!=', '');
        }

        $total = $query->count();

        $clientes = $query->with('clienteCategoria')
            ->orderBy('nombre')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get()
            ->map(function ($c) {
                $c->compras_count = DB::table('ventas')->where('cliente_id', $c->id)->where('estado', 'completada')->count();
                $c->compras_total = DB::table('ventas')->where('cliente_id', $c->id)->where('estado', 'completada')->sum('total') ?? 0;
                $c->clasificacion = $c->clienteCategoria?->nombre ?? $c->clasificacion;
                return $c;
            });

        return response()->json([
            'clientes' => $clientes,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:150',
        ]);

        $lockKey = $this->generateLockKey('crear_cliente', [
            'user' => $request->user()?->id,
            'cedula' => $request->cedula,
            'nombre' => $request->nombre,
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            // Evitar duplicados recientes por cédula
            if ($request->filled('cedula')) {
                $existe = Cliente::where('cedula', $request->cedula)->first();
                if ($existe) {
                    return response()->json(['error' => 'Ya existe un cliente con esta cédula.'], 422);
                }
            }

            $data = $request->only([
                'nombre', 'cedula', 'empresa', 'cedula_juridica', 'telefono', 'email', 'direccion',
                'ciudad', 'pais', 'cliente_categoria_id', 'datos_fiscales', 'credito_tienda',
                'notas', 'activo',
            ]);
            $data['credito_tienda'] = is_numeric($data['credito_tienda'] ?? null) ? $data['credito_tienda'] : 0;
            $data['activo'] = isset($data['activo']) ? (int) $data['activo'] : 1;

            if (!empty($data['cliente_categoria_id'])) {
                $cat = DB::table('cliente_categorias')->where('id', $data['cliente_categoria_id'])->value('nombre');
                $data['clasificacion'] = $cat ?? '';
            } else {
                $data['clasificacion'] = '';
            }

            $cliente = Cliente::create($data);

            if ($request->has('etiqueta_ids')) {
                $cliente->etiquetas()->sync($request->input('etiqueta_ids', []));
            }

            return response()->json(['success' => true, 'cliente' => $cliente, 'message' => 'Cliente creado exitosamente']);
        }, response()->json(['error' => 'Ya se está procesando la creación de este cliente. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $cliente = Cliente::with(['etiquetas', 'clienteCategoria'])->find($id);
        if (!$cliente) return response()->json(['error' => 'Cliente no encontrado'], 404);

        $ultimaNota = ClienteNota::where('cliente_id', $id)
            ->leftJoin('usuarios', 'cliente_notas.usuario_id', '=', 'usuarios.id')
            ->select('cliente_notas.*', 'usuarios.nombre as usuario_nombre')
            ->orderByDesc('cliente_notas.created_at')
            ->first();

        return response()->json(['cliente' => $cliente, 'ultima_nota' => $ultimaNota]);
    }

    public function update(Request $request, $id)
    {
        $cliente = Cliente::find($id);
        if (!$cliente) return response()->json(['error' => 'Cliente no encontrado'], 404);

        $data = $request->only([
            'nombre', 'cedula', 'empresa', 'cedula_juridica', 'telefono', 'email', 'direccion',
            'ciudad', 'pais', 'cliente_categoria_id', 'datos_fiscales', 'credito_tienda',
            'notas', 'activo',
        ]);
        if (array_key_exists('credito_tienda', $data)) {
            $data['credito_tienda'] = is_numeric($data['credito_tienda'] ?? null) ? $data['credito_tienda'] : 0;
        }
        if (array_key_exists('activo', $data)) {
            $data['activo'] = (int) $data['activo'];
        }
        if (array_key_exists('cliente_categoria_id', $data)) {
            if (!empty($data['cliente_categoria_id'])) {
                $cat = DB::table('cliente_categorias')->where('id', $data['cliente_categoria_id'])->value('nombre');
                $data['clasificacion'] = $cat ?? '';
            } else {
                $data['clasificacion'] = '';
            }
        }
        $cliente->update($data);

        if ($request->has('etiqueta_ids')) {
            $cliente->etiquetas()->sync($request->input('etiqueta_ids', []));
        }

        return response()->json(['success' => true, 'cliente' => $cliente, 'message' => 'Cliente actualizado']);
    }

    public function buscar(Request $request)
    {
        $q = trim($request->get('q', ''));
        if (strlen($q) < 1) return response()->json(['clientes' => []]);

        $clientes = Cliente::where('activo', 1)
            ->where(function ($qb) use ($q) {
                $qb->where('nombre', 'LIKE', "%{$q}%")
                    ->orWhere('cedula', 'LIKE', "%{$q}%")
                    ->orWhere('telefono', 'LIKE', "%{$q}%");
            })
            ->select('id', 'nombre', 'cedula', 'telefono', 'email', 'clasificacion', 'credito_tienda')
            ->limit(15)
            ->get();

        return response()->json(['clientes' => $clientes]);
    }

    public function agregarNota(Request $request, $id)
    {
        $request->validate(['contenido' => 'required|string']);

        $nota = ClienteNota::create([
            'cliente_id' => $id,
            'usuario_id' => $request->user()->id,
            'tipo' => $request->tipo ?? 'nota',
            'contenido' => $request->contenido,
        ]);

        return response()->json(['success' => true, 'nota' => $nota]);
    }

    public function notas($id)
    {
        $notas = ClienteNota::where('cliente_id', $id)
            ->leftJoin('usuarios', 'cliente_notas.usuario_id', '=', 'usuarios.id')
            ->select('cliente_notas.*', 'usuarios.nombre as usuario_nombre')
            ->orderByDesc('cliente_notas.created_at')
            ->get();

        return response()->json(['notas' => $notas]);
    }

    public function destroy($id)
    {
        $cliente = Cliente::find($id);
        if (!$cliente) {
            return response()->json(['error' => 'Cliente no encontrado'], 404);
        }

        $ventas = DB::table('ventas')->where('cliente_id', $id)->count();
        if ($ventas > 0) {
            return response()->json(['error' => 'No se puede eliminar el cliente porque tiene ventas registradas.'], 422);
        }

        $cliente->delete();

        return response()->json(['success' => true, 'message' => 'Cliente eliminado']);
    }

    public function notasRecientes()
    {
        $notas = DB::table('cliente_notas as cn')
            ->join('clientes as c', 'cn.cliente_id', '=', 'c.id')
            ->leftJoin('usuarios as u', 'cn.usuario_id', '=', 'u.id')
            ->select('cn.cliente_id', 'cn.contenido', 'cn.tipo', 'cn.created_at', 'u.nombre as usuario_nombre', 'c.nombre as cliente_nombre')
            ->whereIn('cn.id', function ($q) {
                $q->selectRaw('MAX(id)')->from('cliente_notas')->groupBy('cliente_id');
            })
            ->get();

        return response()->json(['notas' => $notas]);
    }

    public function estadisticas()
    {
        $total = Cliente::where('activo', 1)->count();
        $nuevos_mes = Cliente::where('activo', 1)->whereMonth('created_at', now()->month)->count();
        $por_clasificacion = Cliente::where('activo', 1)
            ->selectRaw('clasificacion, COUNT(*) as total')
            ->groupBy('clasificacion')
            ->pluck('total', 'clasificacion');

        return response()->json([
            'total' => $total,
            'nuevos_mes' => $nuevos_mes,
            'por_clasificacion' => $por_clasificacion,
        ]);
    }
}
