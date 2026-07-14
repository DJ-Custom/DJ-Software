<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CotizacionDesignerController extends Controller
{
    public function index()
    {
        $config = DB::table('cotizacion_configuracion')->where('activo', 1)->first();
        if (!$config) {
            $id = DB::table('cotizacion_configuracion')->insertGetId([
                'nombre' => 'default', 'ancho_mm' => 80, 'fuente' => 'Courier New',
                'fuente_size' => 12, 'activo' => true, 'created_at' => now(), 'updated_at' => now(),
            ]);
            $config = DB::table('cotizacion_configuracion')->find($id);
        }
        return response()->json(['config' => $config]);
    }

    public function guardar(Request $request)
    {
        $data = $request->only([
            'ancho_mm', 'fuente', 'fuente_size', 'mostrar_logo', 'mostrar_nombre_negocio',
            'mostrar_direccion', 'mostrar_telefono', 'mostrar_cedula', 'mostrar_vendedor',
            'mostrar_cliente', 'mostrar_fecha', 'mostrar_fecha_vencimiento', 'mostrar_detalle_impuesto',
            'mostrar_descuento', 'mostrar_condiciones', 'mostrar_notas', 'mostrar_codigo_producto',
            'mostrar_validez', 'header_text', 'footer_text', 'condiciones_default', 'notas_default',
            'estilos_custom', 'logo_x', 'logo_y', 'logo_width',
            'color_fondo', 'color_texto', 'color_acento', 'padding_general', 'borde_redondeado',
            'mostrar_separadores', 'formato_moneda', 'elementos_orden',
            'tamano_papel', 'orientacion', 'estilo_layout',
            'color_encabezado', 'color_borde',
            'mostrar_subtitulo', 'subtitulo_text',
            'mostrar_lineas_firma', 'texto_firma_cliente', 'texto_firma_empresa',
            'mostrar_marca_agua', 'marca_agua_texto',
            'mostrar_info_bancaria', 'info_bancaria',
            'mostrar_totales_desglosados', 'mostrar_numero_pagina', 'texto_terminos',
        ]);
        $data['updated_at'] = now();
        if ($request->filled('estilos_custom') && is_array($request->estilos_custom)) {
            $data['estilos_custom'] = json_encode($request->estilos_custom);
        }
        if ($request->filled('elementos_orden') && is_array($request->elementos_orden)) {
            $data['elementos_orden'] = json_encode($request->elementos_orden);
        }
        $config = DB::table('cotizacion_configuracion')->where('activo', 1)->first();
        if ($config) {
            DB::table('cotizacion_configuracion')->where('id', $config->id)->update($data);
        } else {
            $data['nombre'] = 'default'; $data['activo'] = true; $data['created_at'] = now();
            DB::table('cotizacion_configuracion')->insert($data);
        }
        return response()->json(['success' => true]);
    }

    public function subirLogo(Request $request)
    {
        $request->validate(['logo' => 'required|image|max:2048']);
        $path = $request->file('logo')->store('cotizacion-logos', 'public');
        DB::table('cotizacion_configuracion')->where('activo', 1)->update(['logo_path' => $path, 'updated_at' => now()]);
        return response()->json(['success' => true, 'path' => $path]);
    }
}
