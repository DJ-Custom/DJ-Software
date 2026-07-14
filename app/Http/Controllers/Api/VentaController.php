<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Producto;
use App\Models\Venta;
use App\Models\VentaDetalle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class VentaController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->get('page', 1));
        $limit = min(5000, (int) $request->get('limit', 20));

        $query = Venta::query()
            ->leftJoin('usuarios', 'ventas.usuario_id', '=', 'usuarios.id')
            ->leftJoin('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->select('ventas.*', 'usuarios.nombre as cajero', 'clientes.nombre as cliente_nombre', DB::raw('(SELECT COUNT(*) FROM devoluciones WHERE devoluciones.venta_id = ventas.id) as has_devolucion'));

        $desde = $request->fecha_desde ?: $request->desde;
        $hasta = $request->fecha_hasta ?: $request->hasta;
        if ($desde) {
            $query->whereDate('ventas.created_at', '>=', $desde);
        }
        if ($hasta) {
            $query->whereDate('ventas.created_at', '<=', $hasta);
        }
        if ($request->filled('estado')) {
            $query->where('ventas.estado', $request->estado);
        }
        if ($request->filled('ubicacion_id')) {
            $query->where('ventas.ubicacion_id', $request->ubicacion_id);
        }
        $q = $request->busqueda ?: $request->q;
        if ($q) {
            $search = "%{$q}%";
            $query->where(function ($sq) use ($search, $q) {
                $sq->where('ventas.numero_factura', 'like', $search)
                   ->orWhere('clientes.nombre', 'like', $search)
                   ->orWhereRaw("EXISTS (SELECT 1 FROM venta_detalle JOIN productos ON venta_detalle.producto_id = productos.id WHERE venta_detalle.venta_id = ventas.id AND (productos.nombre LIKE ? OR productos.codigo LIKE ?))", [$search, $search]);
            });
        }

        $total = $query->count();
        $ventas = $query->orderByDesc('ventas.created_at')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();

        return response()->json([
            'ventas' => $ventas,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.producto_id' => 'required|integer',
            'items.*.cantidad' => 'required|integer|min:1',
            'metodo_pago' => 'required|string',
        ]);

        $lockKey = $this->generateLockKey('crear_venta', [
            'user' => $request->user()?->id,
            'cliente' => $request->cliente_id,
            'items_hash' => md5(json_encode($request->items)),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $items = $request->items;
            $metodoPago = $request->metodo_pago;
            $clienteId = $request->cliente_id ?: null;
            $montoEfectivo = (float) ($request->monto_efectivo ?? 0);
            $montoTarjeta = (float) ($request->monto_tarjeta ?? 0);
            $montoSinpe = (float) ($request->monto_sinpe ?? 0);
            $referenciaSinpe = $request->referencia_sinpe ?? '';
            $dineroRecibido = (float) ($request->dinero_recibido ?? 0);
            $descuentoTotal = (float) ($request->descuento_total ?? 0);
            $notas = $request->notas ?? '';

            try {
                DB::beginTransaction();

                $ubicacionId = $request->ubicacion_id ?: null;

                $usuarioVenta = $request->user()->id;
                $requerirCaja = DB::table('configuracion')->where('clave', 'requerir_caja_abierta')->value('valor') ?? '0';
                $sesionAbierta = null;
                if ($requerirCaja === '1' || $requerirCaja === 'true') {
                    $sesionAbierta = DB::table('caja_sesiones')
                        ->where('usuario_id', $request->user()->id)
                        ->where('estado', 'abierta')
                        ->first();
                    if (!$sesionAbierta) {
                        DB::rollBack();
                        return response()->json(['error' => 'Debe abrir una caja antes de realizar una venta.'], 400);
                    }
                }

                if (!$sesionAbierta) {
                    $sesionAbierta = DB::table('caja_sesiones')
                        ->where('usuario_id', $request->user()->id)
                        ->where('estado', 'abierta')
                        ->first();
                }

                if ($sesionAbierta) {
                    $cajaAsignada = DB::table('cajas')->where('id', $sesionAbierta->caja_id)->value('usuario_id');
                    if ($cajaAsignada) {
                        $usuarioVenta = $cajaAsignada;
                    }
                }

                $subtotal = 0;
                $impuestoTotal = 0;
                $processedItems = [];

                foreach ($items as $item) {
                    $producto = Producto::where('id', $item['producto_id'])->where('activo', 1)->first();

                    if (!$producto) {
                        DB::rollBack();
                        return response()->json(['error' => "Producto ID {$item['producto_id']} no encontrado"], 400);
                    }

                    $stockUbicacion = $producto->stockUbicacion($ubicacionId);
                    if ($stockUbicacion < $item['cantidad']) {
                        DB::rollBack();
                        return response()->json(['error' => "Stock insuficiente para '{$producto->nombre}' en esta ubicación. Disponible: {$stockUbicacion}"], 400);
                    }

                    $precioUnitario = $producto->precio_venta;
                    $descItem = (float) ($item['descuento'] ?? 0);
                    $impItem = round(($precioUnitario * $item['cantidad'] - $descItem) * ($producto->impuesto / 100), 2);
                    $subItem = ($precioUnitario * $item['cantidad']) - $descItem;

                    $processedItems[] = [
                        'producto_id' => $producto->id,
                        'cantidad' => $item['cantidad'],
                        'precio_unitario' => $precioUnitario,
                        'descuento' => $descItem,
                        'impuesto' => $impItem,
                        'subtotal' => $subItem,
                        'stock_anterior' => $stockUbicacion,
                    ];

                    $subtotal += $subItem;
                    $impuestoTotal += $impItem;
                }

                $total = $subtotal + $impuestoTotal - $descuentoTotal;
                $cambio = 0;

                if ($metodoPago === 'efectivo') {
                    $cambio = $dineroRecibido - $total;
                    $montoEfectivo = $dineroRecibido;
                } elseif ($metodoPago === 'mixto') {
                    $cambio = ($montoEfectivo + $montoTarjeta + $montoSinpe) - $total;
                }

                // Generate invoice number
                $next = Venta::whereDate('created_at', today())->count() + 1;
                $numFactura = 'VTA-' . date('Ymd') . '-' . str_pad($next, 4, '0', STR_PAD_LEFT);

                $venta = Venta::create([
                    'numero_factura' => $numFactura,
                    'cliente_id' => $clienteId,
                    'usuario_id' => $usuarioVenta,
                    'ubicacion_id' => $request->ubicacion_id ?: null,
                    'subtotal' => $subtotal,
                    'descuento_total' => $descuentoTotal,
                    'impuesto_total' => $impuestoTotal,
                    'total' => $total,
                    'metodo_pago' => $metodoPago,
                    'monto_efectivo' => $montoEfectivo,
                    'monto_tarjeta' => $montoTarjeta,
                    'monto_sinpe' => $montoSinpe,
                    'referencia_sinpe' => $referenciaSinpe,
                    'dinero_recibido' => $dineroRecibido,
                    'cambio' => max(0, $cambio),
                    'estado' => 'completada',
                    'notas' => $notas,
                ]);

                foreach ($processedItems as $pi) {
                    VentaDetalle::create([
                        'venta_id' => $venta->id,
                        'producto_id' => $pi['producto_id'],
                        'cantidad' => $pi['cantidad'],
                        'precio_unitario' => $pi['precio_unitario'],
                        'descuento' => $pi['descuento'],
                        'impuesto' => $pi['impuesto'],
                        'subtotal' => $pi['subtotal'],
                    ]);

                    $stockNuevo = $pi['stock_anterior'] - $pi['cantidad'];
                    Producto::where('id', $pi['producto_id'])->update(['stock' => DB::raw("stock - {$pi['cantidad']}")]);

                    if ($ubicacionId) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $pi['producto_id'])
                            ->where('ubicacion_id', $ubicacionId)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad - {$pi['cantidad']}"),
                                'updated_at' => now(),
                            ]);
                        }
                    }

                    DB::table('inventario_movimientos')->insert([
                        'producto_id' => $pi['producto_id'],
                        'tipo' => 'salida',
                        'cantidad' => $pi['cantidad'],
                        'stock_anterior' => $pi['stock_anterior'],
                        'stock_nuevo' => $stockNuevo,
                        'referencia_tipo' => 'venta',
                        'referencia_id' => $venta->id,
                        'usuario_id' => $request->user()->id,
                        'created_at' => now(),
                    ]);
                }

                DB::table('caja_movimientos')->insert([
                    'tipo' => 'ingreso',
                    'monto' => $total,
                    'concepto' => "Venta {$numFactura}",
                    'referencia_tipo' => 'venta',
                    'referencia_id' => $venta->id,
                    'usuario_id' => $request->user()->id,
                    'created_at' => now(),
                ]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'venta_id' => $venta->id,
                    'numero_factura' => $numFactura,
                    'total' => $total,
                    'cambio' => max(0, $cambio),
                    'message' => 'Venta registrada exitosamente',
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => 'Error al procesar la venta: ' . $e->getMessage()], 500);
            }
        }, response()->json(['error' => 'Ya se está procesando esta venta. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $venta = DB::table('ventas')
            ->leftJoin('usuarios', 'ventas.usuario_id', '=', 'usuarios.id')
            ->leftJoin('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->where('ventas.id', $id)
            ->select('ventas.*', 'usuarios.nombre as cajero', 'clientes.nombre as cliente_nombre', 'clientes.cedula as cliente_cedula', 'clientes.telefono as cliente_telefono', DB::raw('(SELECT COUNT(*) FROM devoluciones WHERE devoluciones.venta_id = ventas.id) as has_devolucion'))
            ->first();

        if (!$venta) {
            return response()->json(['error' => 'Venta no encontrada'], 404);
        }

        $items = DB::table('venta_detalle')
            ->join('productos', 'venta_detalle.producto_id', '=', 'productos.id')
            ->where('venta_detalle.venta_id', $id)
            ->select('venta_detalle.*', 'productos.nombre as producto_nombre', 'productos.codigo')
            ->get();

        $venta->items = $items;

        return response()->json(['venta' => $venta]);
    }

    public function cancelar(Request $request, $id)
    {
        $request->validate(['motivo' => 'required|string']);

        try {
            DB::beginTransaction();

            $venta = Venta::where('id', $id)->where('estado', 'completada')->first();
            if (!$venta) {
                return response()->json(['error' => 'Venta no encontrada o ya cancelada'], 400);
            }

            $venta->update([
                'estado' => 'cancelada',
                'cancelada_por' => $request->user()->id,
                'motivo_cancelacion' => $request->motivo,
            ]);

            $detalles = VentaDetalle::where('venta_id', $id)->get();
            foreach ($detalles as $item) {
                $producto = Producto::find($item->producto_id);
                $stockActual = $producto->stock;
                $stockNuevo = $stockActual + $item->cantidad;

                $producto->update(['stock' => DB::raw("stock + {$item->cantidad}")]);

                if ($venta->ubicacion_id) {
                    $existe = DB::table('inventario_ubicacion')
                        ->where('producto_id', $item->producto_id)
                        ->where('ubicacion_id', $venta->ubicacion_id)
                        ->first();
                    if ($existe) {
                        DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                            'cantidad' => DB::raw("cantidad + {$item->cantidad}"),
                            'updated_at' => now(),
                        ]);
                    }
                }

                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $item->producto_id,
                    'tipo' => 'entrada',
                    'cantidad' => $item->cantidad,
                    'stock_anterior' => $stockActual,
                    'stock_nuevo' => $stockNuevo,
                    'referencia_tipo' => 'venta',
                    'referencia_id' => $id,
                    'usuario_id' => $request->user()->id,
                    'notas' => 'Cancelación de venta',
                    'created_at' => now(),
                ]);
            }

            DB::table('caja_movimientos')->insert([
                'tipo' => 'egreso',
                'monto' => $venta->total,
                'concepto' => "Cancelación venta {$venta->numero_factura}",
                'referencia_tipo' => 'venta',
                'referencia_id' => $id,
                'usuario_id' => $request->user()->id,
                'created_at' => now(),
            ]);

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Venta cancelada exitosamente']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Error al cancelar: ' . $e->getMessage()], 500);
        }
    }

    public function buscar(Request $request)
    {
        $q = $request->get('q', '');
        $ventas = DB::table('ventas')
            ->leftJoin('usuarios', 'ventas.usuario_id', '=', 'usuarios.id')
            ->leftJoin('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->where('ventas.numero_factura', 'LIKE', "%{$q}%")
            ->orWhere('clientes.nombre', 'LIKE', "%{$q}%")
            ->orderByDesc('ventas.created_at')
            ->limit(20)
            ->select('ventas.*', 'usuarios.nombre as cajero', 'clientes.nombre as cliente_nombre', DB::raw('(SELECT COUNT(*) FROM devoluciones WHERE devoluciones.venta_id = ventas.id) as has_devolucion'))
            ->get();

        return response()->json(['ventas' => $ventas]);
    }

    public function ticket($id)
    {
        $venta = DB::table('ventas')
            ->leftJoin('usuarios', 'ventas.usuario_id', '=', 'usuarios.id')
            ->leftJoin('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->where('ventas.id', $id)
            ->select('ventas.*', 'usuarios.nombre as cajero', 'clientes.nombre as cliente_nombre')
            ->first();

        if (!$venta) {
            return response()->json(['error' => 'Venta no encontrada'], 404);
        }

        $items = DB::table('venta_detalle')
            ->join('productos', 'venta_detalle.producto_id', '=', 'productos.id')
            ->where('venta_detalle.venta_id', $id)
            ->select('venta_detalle.*', 'productos.nombre as producto_nombre', 'productos.codigo')
            ->get();

        $venta->items = $items;

        $config = DB::table('configuracion')->pluck('valor', 'clave')->toArray();

        return response()->json(['venta' => $venta, 'config' => $config]);
    }
}
