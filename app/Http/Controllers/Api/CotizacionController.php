<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SmtpConfigHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class CotizacionController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $isAdmin = ($user->rol->nombre ?? '') === 'admin' || ($user->rol->nombre ?? '') === 'Administrador';
        $canViewAll = $isAdmin || in_array('cotizaciones_ver_todas', $user->permisos ?? []);

        $query = DB::table('cotizaciones as c')
            ->leftJoin('clientes as cl', 'c.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'c.usuario_id', '=', 'u.id')
            ->select('c.*', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre');

        if (!$canViewAll) {
            $query->where('c.usuario_id', $user->id);
        }

        if ($request->estado) $query->where('c.estado', $request->estado);
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('c.numero_cotizacion', 'like', "%{$request->q}%")
                  ->orWhere('cl.nombre', 'like', "%{$request->q}%");
            });
        }

        $data = $query->orderByDesc('c.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['items' => 'required|array|min:1']);

        $lockKey = $this->generateLockKey('crear_cotizacion', [
            'user' => $request->user()?->id,
            'cliente' => $request->cliente_id,
            'items_hash' => md5(json_encode($request->items)),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            try {
                DB::beginTransaction();
                $date = date('Ymd');
                $cnt = DB::table('cotizaciones')->whereDate('created_at', today())->count() + 1;
                $numCot = 'COT-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

                $cotId = DB::table('cotizaciones')->insertGetId([
                    'numero_cotizacion' => $numCot,
                    'cliente_id' => $request->cliente_id,
                    'usuario_id' => $request->user()->id,
                    'subtotal' => 0, 'descuento_total' => $request->descuento_total ?? 0,
                    'impuesto_total' => 0, 'total' => 0,
                    'estado' => 'pendiente',
                    'fecha_vencimiento' => $request->fecha_vencimiento,
                    'condiciones' => $request->condiciones,
                    'notas' => $request->notas,
                    'created_at' => now(), 'updated_at' => now(),
                ]);

                $subtotal = 0; $impuestoTotal = 0;
                foreach ($request->items as $item) {
                    $prod = DB::table('productos')->where('id', $item['producto_id'])->first();
                    $impPct = $prod ? (float)$prod->impuesto : 0;
                    $subItem = ($item['precio_unitario'] * $item['cantidad']) - ($item['descuento'] ?? 0);
                    $impItem = round($subItem * $impPct / 100, 2);
                    $subtotal += $subItem; $impuestoTotal += $impItem;

                    DB::table('cotizacion_detalle')->insert([
                        'cotizacion_id' => $cotId, 'producto_id' => $item['producto_id'],
                        'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                        'descuento' => $item['descuento'] ?? 0, 'impuesto' => $impItem, 'subtotal' => $subItem,
                        'created_at' => now(),
                    ]);
                }

                $total = $subtotal + $impuestoTotal - ($request->descuento_total ?? 0);
                DB::table('cotizaciones')->where('id', $cotId)->update([
                    'subtotal' => $subtotal, 'impuesto_total' => $impuestoTotal, 'total' => $total,
                ]);

                DB::commit();
                return response()->json(['success' => true, 'cotizacion_id' => $cotId, 'numero_cotizacion' => $numCot]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => $e->getMessage()], 500);
            }
        }, response()->json(['error' => 'Ya se está procesando esta cotización. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $cot = DB::table('cotizaciones as c')
            ->leftJoin('clientes as cl', 'c.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'c.usuario_id', '=', 'u.id')
            ->where('c.id', $id)
            ->select('c.*', 'cl.nombre as cliente_nombre', 'cl.cedula as cliente_cedula', 'cl.telefono as cliente_telefono', 'cl.email as cliente_email', 'cl.direccion as cliente_direccion', 'u.nombre as usuario_nombre')
            ->first();
        if (!$cot) return response()->json(['error' => 'No encontrada'], 404);

        $cot->items = DB::table('cotizacion_detalle as d')
            ->join('productos as p', 'd.producto_id', '=', 'p.id')
            ->where('d.cotizacion_id', $id)
            ->select('d.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        return response()->json(['cotizacion' => $cot]);
    }

    public function cambiarEstado(Request $request, $id)
    {
        DB::table('cotizaciones')->where('id', $id)->update(['estado' => $request->estado, 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }

    public function aprobar(Request $request, $id)
    {
        $cot = DB::table('cotizaciones')->where('id', $id)->first();
        if (!$cot) return response()->json(['error' => 'Cotización no encontrada'], 404);
        if ($cot->estado !== 'pendiente') return response()->json(['error' => 'Solo se pueden aprobar cotizaciones pendientes'], 422);

        DB::table('cotizaciones')->where('id', $id)->update([
            'estado' => 'aprobada',
            'estado_aprobacion' => 'aprobada',
            'aprobado_en' => now(),
            'aprobado_por' => $request->user()->id,
            'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function rechazar(Request $request, $id)
    {
        $request->validate(['motivo' => 'required|string|max:500']);
        $cot = DB::table('cotizaciones')->where('id', $id)->first();
        if (!$cot) return response()->json(['error' => 'Cotización no encontrada'], 404);
        if ($cot->estado !== 'pendiente') return response()->json(['error' => 'Solo se pueden rechazar cotizaciones pendientes'], 422);

        DB::table('cotizaciones')->where('id', $id)->update([
            'estado' => 'rechazada',
            'estado_aprobacion' => 'rechazada',
            'motivo_rechazo' => $request->motivo,
            'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function convertirFactura(Request $request, $id)
    {
        $cot = DB::table('cotizaciones')->where('id', $id)->first();
        if (!$cot) return response()->json(['error' => 'Cotización no encontrada'], 404);
        if ($cot->estado !== 'aprobada') return response()->json(['error' => 'Solo cotizaciones aprobadas pueden convertirse en factura'], 422);

        try {
            DB::beginTransaction();

            $date = date('Ymd');
            $cnt = DB::table('ventas')->whereDate('created_at', today())->count() + 1;
            $numFactura = 'FAC-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

            $ventaId = DB::table('ventas')->insertGetId([
                'numero_factura' => $numFactura,
                'cliente_id' => $cot->cliente_id,
                'usuario_id' => $request->user()->id,
                'subtotal' => $cot->subtotal,
                'descuento_total' => $cot->descuento_total ?? 0,
                'impuesto_total' => $cot->impuesto_total,
                'total' => $cot->total,
                'metodo_pago' => 'pendiente',
                'estado' => 'completada',
                'cotizacion_id' => $id,
                'notas' => 'Generada desde cotización ' . $cot->numero_cotizacion,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $items = DB::table('cotizacion_detalle')->where('cotizacion_id', $id)->get();
            foreach ($items as $item) {
                DB::table('venta_detalle')->insert([
                    'venta_id' => $ventaId,
                    'producto_id' => $item->producto_id,
                    'cantidad' => $item->cantidad,
                    'precio_unitario' => $item->precio_unitario,
                    'descuento' => $item->descuento ?? 0,
                    'impuesto' => $item->impuesto ?? 0,
                    'subtotal' => $item->subtotal,
                    'created_at' => now(),
                ]);
            }

            DB::table('cotizaciones')->where('id', $id)->update([
                'estado' => 'facturada',
                'updated_at' => now(),
            ]);

            DB::commit();
            return response()->json(['success' => true, 'venta_id' => $ventaId, 'numero_factura' => $numFactura]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Error al crear factura: ' . $e->getMessage()], 500);
        }
    }

    public function enviar(Request $request)
    {
        $request->validate([
            'cotizacion_id' => 'required|integer',
            'cliente_ids' => 'nullable|array',
            'cliente_ids.*' => 'integer',
            'emails' => 'nullable|array',
            'emails.*' => 'email',
            'nota' => 'nullable|string|max:2000',
        ]);

        $cot = DB::table('cotizaciones as c')
            ->leftJoin('clientes as cl', 'c.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'c.usuario_id', '=', 'u.id')
            ->where('c.id', $request->cotizacion_id)
            ->select('c.*', 'cl.nombre as cliente_nombre', 'cl.email as cliente_email', 'u.nombre as usuario_nombre')
            ->first();

        if (!$cot) return response()->json(['error' => 'Cotización no encontrada'], 404);

        $items = DB::table('cotizacion_detalle as d')
            ->join('productos as p', 'd.producto_id', '=', 'p.id')
            ->where('d.cotizacion_id', $request->cotizacion_id)
            ->select('d.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        // Remitente
        $fromEmail = DB::table('configuracion')->where('clave', 'email_remitente')->value('valor') ?? '';
        if (!$fromEmail || !filter_var($fromEmail, FILTER_VALIDATE_EMAIL)) {
            $fromEmail = DB::table('configuracion')->where('clave', 'email_negocio')->value('valor') ?? '';
        }
        if (!$fromEmail || !filter_var($fromEmail, FILTER_VALIDATE_EMAIL)) {
            return response()->json(['error' => 'No hay un correo remitente configurado. Ve a Configuración > Empresa y define el "Email remitente".'], 422);
        }
        $fromName = DB::table('configuracion')->where('clave', 'nombre_negocio')->value('valor') ?? 'Sistema';

        // Aplicar configuración SMTP desde la base de datos
        SmtpConfigHelper::aplicarConfiguracion();

        // Destinatarios
        $destinatarios = [];

        if ($request->filled('cliente_ids')) {
            $clientes = DB::table('clientes')
                ->whereIn('id', $request->cliente_ids)
                ->whereNotNull('email')->where('email', '!=', '')
                ->select('id', 'nombre', 'email')->get();
            foreach ($clientes as $c) {
                $destinatarios[] = ['email' => $c->email, 'nombre' => $c->nombre, 'tipo' => 'cliente', 'id' => $c->id];
            }
        }

        if ($request->filled('emails')) {
            foreach ($request->emails as $email) {
                $email = strtolower(trim($email));
                if (filter_var($email, FILTER_VALIDATE_EMAIL) && !collect($destinatarios)->pluck('email')->contains($email)) {
                    $destinatarios[] = ['email' => $email, 'nombre' => null, 'tipo' => 'email', 'id' => null];
                }
            }
        }

        if (empty($destinatarios)) {
            return response()->json(['error' => 'Debes seleccionar al menos un destinatario (cliente o email)'], 422);
        }

        $html = $this->buildCotizacionHtml($cot, $items, $request->nota);
        $asunto = 'Cotización ' . $cot->numero_cotizacion . ' - ' . $fromName;

        $enviados = 0;
        $errores = [];
        foreach ($destinatarios as $dest) {
            try {
                Mail::html($html, function ($msg) use ($asunto, $dest, $fromEmail, $fromName) {
                    $msg->to($dest['email'], $dest['nombre'])
                        ->subject($asunto)
                        ->from($fromEmail, $fromName);
                });
                $enviados++;
            } catch (\Throwable $e) {
                $errores[] = $dest['email'] . ': ' . substr($e->getMessage(), 0, 120);
            }
        }

        return response()->json([
            'success' => true,
            'enviados' => $enviados,
            'total' => count($destinatarios),
            'errores' => $errores,
        ]);
    }

    private function buildCotizacionHtml($cot, $items, $nota = null)
    {
        $empresa = DB::table('configuracion')
            ->whereIn('clave', ['nombre_negocio', 'telefono', 'direccion', 'email_negocio'])
            ->pluck('valor', 'clave');

        $rows = '';
        foreach ($items as $item) {
            $rows .= '<tr>
                <td style="padding:14px 10px;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;">' . ($item->codigo ? '<span style="display:block;font-size:11px;color:#64748b;font-weight:600;margin-bottom:2px;">' . $item->codigo . '</span>' : '') . '<strong>' . $item->producto_nombre . '</strong></td>
                <td style="padding:14px 10px;text-align:center;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;font-weight:600;">' . $item->cantidad . '</td>
                <td style="padding:14px 10px;text-align:right;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;">₡' . number_format($item->precio_unitario, 0) . '</td>
                <td style="padding:14px 10px;text-align:right;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;font-weight:700;">₡' . number_format($item->subtotal, 0) . '</td>
            </tr>';
        }

        $estadoColor = match($cot->estado) {
            'aprobada' => '#047857',
            'rechazada' => '#dc2626',
            'facturada' => '#2563eb',
            default => '#d97706',
        };
        $estadoBg = match($cot->estado) {
            'aprobada' => '#ecfdf5',
            'rechazada' => '#fef2f2',
            'facturada' => '#eff6ff',
            default => '#fffbeb',
        };

        $notaHtml = $nota ? '<div style="margin-top:24px;padding:16px;background:#f0f9ff;border-left:4px solid #0284c7;border-radius:8px;"><strong style="color:#0369a1;font-size:14px;">Nota adicional</strong><p style="margin:8px 0 0 0;font-size:14px;color:#334155;line-height:1.5;">' . nl2br(e($nota)) . '</p></div>' : '';

        return '<!DOCTYPE html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Cotización ' . $cot->numero_cotizacion . '</title></head>
<body style="margin:0;padding:32px 16px;background:#0f172a;font-family:\'Segoe UI\',system-ui,-apple-system,sans-serif;-webkit-font-smoothing:antialiased;">
<div style="max-width:680px;margin:0 auto;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 25px 50px -12px rgba(0,0,0,0.4);border:1px solid #1e293b;">

  <!-- Header -->
  <div style="background:linear-gradient(135deg,#0e3b58 0%,#006bb3 50%,#0ea5e9 100%);padding:32px 36px;color:#fff;position:relative;">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px;">
      <div>
        <div style="font-size:24px;font-weight:800;letter-spacing:-0.5px;">' . ($empresa['nombre_negocio'] ?? 'Software DJ') . '</div>
        <div style="font-size:13px;opacity:0.9;margin-top:6px;line-height:1.5;">
          ' . ($empresa['direccion'] ? '<span>' . $empresa['direccion'] . '</span><br/>' : '') . '
          ' . ($empresa['telefono'] ? '<span>Tel: ' . $empresa['telefono'] . '</span>' : '') . '
        </div>
      </div>
      <div style="text-align:right;background:rgba(255,255,255,0.12);padding:12px 20px;border-radius:12px;backdrop-filter:blur(8px);">
        <div style="font-size:11px;opacity:0.85;text-transform:uppercase;letter-spacing:1px;">Cotización</div>
        <div style="font-size:20px;font-weight:800;letter-spacing:0.5px;margin-top:2px;">' . $cot->numero_cotizacion . '</div>
      </div>
    </div>
  </div>

  <!-- Meta Info -->
  <div style="padding:28px 36px;background:#f8fafc;border-bottom:1px solid #e2e8f0;">
    <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px;">
      <div>
        <div style="font-size:11px;color:#64748b;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;margin-bottom:4px;">Cliente</div>
        <div style="font-size:16px;font-weight:700;color:#0f172a;">' . ($cot->cliente_nombre ?? 'Cliente general') . '</div>
      </div>
      <div style="text-align:right;">
        <div style="font-size:13px;color:#475569;margin-bottom:4px;"><strong style="color:#0f172a;">Fecha:</strong> ' . date('d/m/Y', strtotime($cot->created_at)) . '</div>
        <div style="font-size:13px;color:#475569;margin-bottom:6px;"><strong style="color:#0f172a;">Vence:</strong> ' . ($cot->fecha_vencimiento ? date('d/m/Y', strtotime($cot->fecha_vencimiento)) : 'N/A') . '</div>
        <span style="display:inline-block;padding:5px 14px;border-radius:9999px;background:' . $estadoBg . ';color:' . $estadoColor . ';font-weight:700;font-size:12px;letter-spacing:0.3px;text-transform:uppercase;">' . $cot->estado . '</span>
      </div>
    </div>
  </div>

  <!-- Table -->
  <div style="padding:0 36px 28px;">
    <table style="width:100%;border-collapse:separate;border-spacing:0;font-size:14px;margin-top:24px;">
      <thead>
        <tr style="background:#0f172a;">
          <th style="padding:14px 10px;text-align:left;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;border-radius:8px 0 0 0;">Producto</th>
          <th style="padding:14px 10px;text-align:center;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;">Cant.</th>
          <th style="padding:14px 10px;text-align:right;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;">Precio Unit.</th>
          <th style="padding:14px 10px;text-align:right;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;border-radius:0 8px 0 0;">Subtotal</th>
        </tr>
      </thead>
      <tbody>' . $rows . '</tbody>
    </table>

    <!-- Totals -->
    <div style="margin-top:8px;padding:24px;background:#f8fafc;border-radius:12px;border:1px solid #e2e8f0;">
      <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px;">
        <div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>Subtotal</span><span style="font-weight:600;color:#0f172a;">₡' . number_format($cot->subtotal, 0) . '</span></div>
        ' . ($cot->descuento_total > 0 ? '<div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>Descuento</span><span style="font-weight:600;color:#dc2626;">-₡' . number_format($cot->descuento_total, 0) . '</span></div>' : '') . '
        ' . ($cot->impuesto_total > 0 ? '<div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>Impuestos</span><span style="font-weight:600;color:#0f172a;">₡' . number_format($cot->impuesto_total, 0) . '</span></div>' : '') . '
        <div style="display:flex;justify-content:space-between;width:260px;margin-top:10px;padding-top:12px;border-top:2px solid #0f172a;">
          <span style="font-size:16px;font-weight:800;color:#0f172a;">TOTAL</span>
          <span style="font-size:20px;font-weight:800;color:#006bb3;">₡' . number_format($cot->total, 0) . '</span>
        </div>
      </div>
    </div>

    ' . $notaHtml . '

    ' . ($cot->condiciones ? '<div style="margin-top:24px;padding:16px;background:#fefce8;border:1px solid #fde047;border-radius:8px;"><strong style="color:#854d0e;font-size:14px;">Condiciones</strong><p style="margin:8px 0 0 0;font-size:13px;color:#713f12;line-height:1.6;">' . nl2br(e($cot->condiciones)) . '</p></div>' : '') . '
  </div>

  <!-- Footer -->
  <div style="background:#0f172a;padding:24px 36px;text-align:center;color:#94a3b8;font-size:13px;line-height:1.6;">
    <div style="font-weight:600;color:#e2e8f0;margin-bottom:4px;">Este documento es una cotización y no constituye una factura</div>
    <div>Para aprobar o realizar consultas, comuníquese con nosotros' . ($empresa['telefono'] ? ' al ' . $empresa['telefono'] : '') . ' o responda este correo.</div>
  </div>

</div>
</body></html>';
    }
}
