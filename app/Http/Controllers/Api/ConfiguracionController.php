<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SmtpConfigHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ConfiguracionController extends Controller
{
    public function index()
    {
        $configs = DB::table('configuracion')->get()->pluck('valor', 'clave');
        $configs = collect($configs);
        if (!isset($configs['requerir_caja_abierta'])) {
            $configs['requerir_caja_abierta'] = '0';
        }
        // Empresa y General se consolidan: eliminar duplicidad
        return response()->json(['config' => $configs]);
    }

    public function guardar(Request $request)
    {
        foreach ($request->config ?? [] as $clave => $valor) {
            DB::table('configuracion')->updateOrInsert(['clave' => $clave], ['valor' => $valor, 'updated_at' => now()]);
        }
        return response()->json(['success' => true]);
    }

    public function empresa()
    {
        $keys = ['nombre_negocio','telefono','direccion','moneda','simbolo_moneda','impuesto_default',
            'ticket_footer','sinpe_numero','email_negocio','email_remitente','cedula_juridica','logo_path','website'];
        $result = [];
        foreach ($keys as $k) {
            $result[$k] = DB::table('configuracion')->where('clave', $k)->value('valor') ?? '';
        }
        return response()->json(['empresa' => $result]);
    }

    public function guardarEmpresa(Request $request)
    {
        foreach ($request->all() as $clave => $valor) {
            if ($clave === '_token') continue;
            DB::table('configuracion')->updateOrInsert(['clave' => $clave], ['valor' => $valor, 'updated_at' => now()]);
        }
        return response()->json(['success' => true, 'message' => 'Configuración guardada']);
    }

    public function ubicaciones()
    {
        $ubicaciones = DB::table('ubicaciones')->orderByDesc('es_principal')->orderBy('nombre')->get();
        return response()->json(['ubicaciones' => $ubicaciones]);
    }

    public function crearUbicacion(Request $request)
    {
        $request->validate(['nombre' => 'required|string']);
        $id = DB::table('ubicaciones')->insertGetId([
            'nombre' => $request->nombre, 'tipo' => $request->tipo ?? 'sucursal',
            'direccion' => $request->direccion, 'telefono' => $request->telefono,
            'responsable' => $request->responsable,
            'lat' => $request->lat ?: null, 'lng' => $request->lng ?: null,
            'activo' => true,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    public function actualizarUbicacion(Request $request, $id)
    {
        $data = [
            'nombre' => $request->nombre, 'tipo' => $request->tipo,
            'direccion' => $request->direccion, 'telefono' => $request->telefono,
            'responsable' => $request->responsable,
            'updated_at' => now(),
        ];
        if ($request->has('lat')) $data['lat'] = $request->lat ?: null;
        if ($request->has('lng')) $data['lng'] = $request->lng ?: null;
        if ($request->has('activo')) $data['activo'] = $request->activo;

        DB::table('ubicaciones')->where('id', $id)->update($data);
        return response()->json(['success' => true]);
    }

    public function cajas()
    {
        $cajas = DB::table('cajas as c')
            ->leftJoin('ubicaciones as u', 'c.ubicacion_id', '=', 'u.id')
            ->leftJoin('usuarios as us', 'c.usuario_id', '=', 'us.id')
            ->select('c.*', 'u.nombre as ubicacion_nombre', 'us.nombre as usuario_nombre')
            ->orderBy('c.nombre')
            ->get();
        return response()->json(['cajas' => $cajas]);
    }

    public function crearCaja(Request $request)
    {
        try {
            $request->validate(['nombre' => 'required|string|max:100']);
            $id = DB::table('cajas')->insertGetId([
                'nombre' => $request->nombre,
                'ubicacion_id' => $request->ubicacion_id ?: null,
                'usuario_id' => $request->usuario_id ?: null,
                'activo' => $request->boolean('activo', true),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            return response()->json(['success' => true, 'id' => $id]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['error' => $e->getMessage(), 'errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al crear la caja: ' . $e->getMessage()], 500);
        }
    }

    public function actualizarCaja(Request $request, $id)
    {
        $data = ['updated_at' => now()];
        if ($request->has('nombre')) $data['nombre'] = $request->nombre;
        if ($request->has('ubicacion_id')) $data['ubicacion_id'] = $request->ubicacion_id;
        if ($request->has('usuario_id')) $data['usuario_id'] = $request->usuario_id;
        if ($request->has('activo')) $data['activo'] = $request->activo;
        DB::table('cajas')->where('id', $id)->update($data);
        return response()->json(['success' => true]);
    }

    public function categorias()
    {
        $categorias = DB::table('categorias')->orderBy('nombre')->get();
        return response()->json(['categorias' => $categorias]);
    }

    public function crearCategoria(Request $request)
    {
        $request->validate(['nombre' => 'required|string|max:100|unique:categorias,nombre']);
        $id = DB::table('categorias')->insertGetId([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'color' => $request->color ?? '#3b82f6',
            'icono' => $request->icono,
            'activo' => $request->activo ?? true,
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    public function actualizarCategoria(Request $request, $id)
    {
        $request->validate(['nombre' => ['required', 'string', 'max:100', Rule::unique('categorias', 'nombre')->ignore($id)]]);

        DB::table('categorias')->where('id', $id)->update(array_filter([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'color' => $request->color,
            'icono' => $request->icono,
            'activo' => $request->activo,
        ], fn($v) => $v !== null));
        return response()->json(['success' => true]);
    }

    public function tasasCambio()
    {
        $usd = DB::table('configuracion')->where('clave', 'tasa_usd')->value('valor') ?? '520';
        $eur = DB::table('configuracion')->where('clave', 'tasa_eur')->value('valor') ?? '570';
        return response()->json(['tasas' => ['USD' => (float) $usd, 'EUR' => (float) $eur]]);
    }

    public function guardarTasasCambio(Request $request)
    {
        $request->validate(['USD' => 'required|numeric|min:0', 'EUR' => 'required|numeric|min:0']);
        DB::table('configuracion')->updateOrInsert(
            ['clave' => 'tasa_usd'],
            ['valor' => (string) $request->USD, 'created_at' => now(), 'updated_at' => now()]
        );
        DB::table('configuracion')->updateOrInsert(
            ['clave' => 'tasa_eur'],
            ['valor' => (string) $request->EUR, 'created_at' => now(), 'updated_at' => now()]
        );
        return response()->json(['success' => true]);
    }

    public function idioma(Request $request)
    {
        $request->validate(['idioma' => 'required|string|in:es,en']);
        DB::table('configuracion')->updateOrInsert(
            ['clave' => 'idioma'],
            ['valor' => $request->idioma, 'created_at' => now(), 'updated_at' => now()]
        );
        return response()->json(['success' => true]);
    }

    public function divisa(Request $request)
    {
        $request->validate(['divisa' => 'required|string|in:CRC,USD,EUR']);
        DB::table('configuracion')->updateOrInsert(
            ['clave' => 'divisa'],
            ['valor' => $request->divisa, 'created_at' => now(), 'updated_at' => now()]
        );
        return response()->json(['success' => true]);
    }

    public function obtenerPreferencias()
    {
        $idioma = DB::table('configuracion')->where('clave', 'idioma')->value('valor') ?? 'es';
        $divisa = DB::table('configuracion')->where('clave', 'divisa')->value('valor') ?? 'CRC';
        $usd = DB::table('configuracion')->where('clave', 'tasa_usd')->value('valor') ?? '520';
        $eur = DB::table('configuracion')->where('clave', 'tasa_eur')->value('valor') ?? '570';
        return response()->json([
            'idioma' => $idioma,
            'divisa' => $divisa,
            'tasas' => ['USD' => (float) $usd, 'EUR' => (float) $eur],
        ]);
    }

    public function retencionChats()
    {
        $retencion = DB::table('configuracion')->where('clave', 'chat_retencion')->value('valor') ?? 'never';
        $totalChats = DB::table('chats')->count();
        $totalMensajes = DB::table('chat_mensajes')->count();
        $totalArchivos = DB::table('chat_mensajes')->whereNotNull('archivo_url')->count();
        return response()->json([
            'retencion' => $retencion,
            'total_chats' => $totalChats,
            'total_mensajes' => $totalMensajes,
            'total_archivos' => $totalArchivos,
        ]);
    }

    public function guardarRetencionChats(Request $request)
    {
        $request->validate(['retencion' => 'required|string|in:3m,6m,1y,2y,never']);
        DB::table('configuracion')->updateOrInsert(
            ['clave' => 'chat_retencion'],
            ['valor' => $request->retencion, 'created_at' => now(), 'updated_at' => now()]
        );
        return response()->json(['success' => true, 'retencion' => $request->retencion]);
    }

    public function limpiarChats(Request $request)
    {
        $request->validate(['tipo' => 'required|string|in:retencion,all']);
        $tipo = $request->tipo;

        $retencion = DB::table('configuracion')->where('clave', 'chat_retencion')->value('valor') ?? 'never';
        $cutoff = null;

        if ($tipo === 'retencion') {
            if ($retencion === 'never') {
                return response()->json(['error' => 'La retención está configurada como "Nunca borrar". Cambia la configuración primero.'], 422);
            }
            $cutoff = match ($retencion) {
                '3m' => now()->subMonths(3),
                '6m' => now()->subMonths(6),
                '1y' => now()->subYear(),
                '2y' => now()->subYears(2),
                default => now()->subYear(),
            };
        }

        try {
            DB::beginTransaction();

            $mensajesQuery = DB::table('chat_mensajes');
            if ($cutoff) {
                $mensajesQuery->where('created_at', '<', $cutoff);
            }
            $mensajes = $mensajesQuery->get();

            $eliminadosMensajes = 0;
            $eliminadosArchivos = 0;

            foreach ($mensajes as $m) {
                if ($m->archivo_url) {
                    if (Storage::disk('public')->exists($m->archivo_url)) {
                        Storage::disk('public')->delete($m->archivo_url);
                        $eliminadosArchivos++;
                    }
                }
            }

            if ($cutoff) {
                $eliminadosMensajes = DB::table('chat_mensajes')->where('created_at', '<', $cutoff)->delete();
            } else {
                $eliminadosMensajes = DB::table('chat_mensajes')->delete();
            }

            if ($cutoff) {
                $chatIdsConMensajes = DB::table('chat_mensajes')->pluck('chat_id')->unique()->toArray();
                $chatsVacios = DB::table('chats')->whereNotIn('id', $chatIdsConMensajes)->pluck('id')->toArray();
                if (!empty($chatsVacios)) {
                    DB::table('chat_participantes')->whereIn('chat_id', $chatsVacios)->delete();
                    DB::table('chats')->whereIn('id', $chatsVacios)->delete();
                }
            } else {
                DB::table('chat_participantes')->delete();
                DB::table('chats')->delete();
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'mensajes_eliminados' => $eliminadosMensajes,
                'archivos_eliminados' => $eliminadosArchivos,
                'tipo' => $tipo,
                'cutoff' => $cutoff?->toDateTimeString(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Error al limpiar chats: ' . $e->getMessage()], 500);
        }
    }

    public function clienteCategorias()
    {
        $categorias = DB::table('cliente_categorias')->orderBy('nombre')->get();
        return response()->json(['categorias' => $categorias]);
    }

    public function crearClienteCategoria(Request $request)
    {
        $request->validate(['nombre' => 'required|string|max:100|unique:cliente_categorias,nombre']);
        $id = DB::table('cliente_categorias')->insertGetId([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'color' => $request->color ?? '#3b82f6',
            'icono' => $request->icono,
            'activo' => $request->activo ?? true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    public function actualizarClienteCategoria(Request $request, $id)
    {
        $request->validate(['nombre' => ['required', 'string', 'max:100', Rule::unique('cliente_categorias', 'nombre')->ignore($id)]]);

        DB::table('cliente_categorias')->where('id', $id)->update(array_filter([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'color' => $request->color,
            'icono' => $request->icono,
            'activo' => $request->activo,
            'updated_at' => now(),
        ], fn($v) => $v !== null));
        return response()->json(['success' => true]);
    }

    // ================= SMTP / EMAIL =================

    public function smtpConfig()
    {
        return response()->json(['smtp' => SmtpConfigHelper::obtenerConfiguracion()]);
    }

    public function guardarSmtp(Request $request)
    {
        $request->validate([
            'smtp_host'       => 'required|string|max:255',
            'smtp_port'       => 'required|integer|min:1|max:65535',
            'smtp_username'   => 'required|string|max:255',
            'smtp_password'   => 'nullable|string|max:255',
            'smtp_encryption' => 'required|string|in:tls,ssl',
            'smtp_activo'     => 'required|string|in:0,1',
        ]);

        $data = $request->only([
            'smtp_host', 'smtp_port', 'smtp_username',
            'smtp_password', 'smtp_encryption', 'smtp_activo',
        ]);

        // No sobrescribir la contraseña si se envía enmascarada
        if (!empty($data['smtp_password']) && preg_match('/^\*+$/', $data['smtp_password'])) {
            unset($data['smtp_password']);
        }

        SmtpConfigHelper::guardarConfiguracion($data);

        // Si SMTP se activó, aplicar configuración inmediatamente
        if (($data['smtp_activo'] ?? '0') === '1') {
            SmtpConfigHelper::aplicarConfiguracion();
        }

        return response()->json(['success' => true, 'message' => 'Configuración SMTP guardada']);
    }

    public function probarSmtp()
    {
        $resultado = SmtpConfigHelper::probarConexion();
        $statusCode = $resultado['success'] ? 200 : 500;
        return response()->json($resultado, $statusCode);
    }
}
