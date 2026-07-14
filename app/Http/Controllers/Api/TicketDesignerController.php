<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TicketDesignerController extends Controller
{
    public function index()
    {
        $config = DB::table('ticket_configuracion')->where('activo', 1)->first();
        if (!$config) {
            $id = DB::table('ticket_configuracion')->insertGetId([
                'nombre' => 'default', 'ancho_mm' => 80, 'fuente' => 'Courier New',
                'fuente_size' => 12, 'activo' => true, 'created_at' => now(), 'updated_at' => now(),
            ]);
            $config = DB::table('ticket_configuracion')->find($id);
        }
        return response()->json(['config' => $config]);
    }

    public function guardar(Request $request)
    {
        $data = $request->only([
            'ancho_mm', 'fuente', 'fuente_size', 'mostrar_logo', 'mostrar_nombre_negocio',
            'mostrar_direccion', 'mostrar_telefono', 'mostrar_cedula', 'mostrar_vendedor',
            'mostrar_cliente', 'mostrar_fecha', 'mostrar_detalle_impuesto', 'mostrar_descuento',
            'mostrar_metodo_pago', 'mostrar_codigo_producto', 'mostrar_sinpe_info',
            'header_text', 'footer_text', 'estilos_custom',
            'logo_x', 'logo_y', 'logo_width',
        ]);
        $data['updated_at'] = now();
        if ($request->filled('estilos_custom') && is_array($request->estilos_custom)) {
            $data['estilos_custom'] = json_encode($request->estilos_custom);
        }
        $config = DB::table('ticket_configuracion')->where('activo', 1)->first();
        if ($config) {
            DB::table('ticket_configuracion')->where('id', $config->id)->update($data);
        } else {
            $data['nombre'] = 'default'; $data['activo'] = true; $data['created_at'] = now();
            DB::table('ticket_configuracion')->insert($data);
        }
        return response()->json(['success' => true]);
    }

    public function subirLogo(Request $request)
    {
        $request->validate(['logo' => 'required|image|max:2048']);
        $path = $request->file('logo')->store('ticket-logos', 'public');
        DB::table('ticket_configuracion')->where('activo', 1)->update(['logo_path' => $path, 'updated_at' => now()]);
        return response()->json(['success' => true, 'path' => $path]);
    }
}
