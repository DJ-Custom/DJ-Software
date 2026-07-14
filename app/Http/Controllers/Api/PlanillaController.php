<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Empleado;
use App\Models\PlanillaConfiguracion;
use App\Models\PlanillaHistorial;
use App\Models\PlanillaPago;
use App\Models\PlanillaPlantilla;
use App\Models\PlanillaVariable;
use App\Services\FormulaEvaluator;
use App\Services\FormulaParser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class PlanillaController extends Controller
{
    private FormulaParser $parser;
    private FormulaEvaluator $evaluator;

    public function __construct(FormulaParser $parser, FormulaEvaluator $evaluator)
    {
        $this->parser = $parser;
        $this->evaluator = $evaluator;
    }

    // ══════════════════════════════════════════════════════════════
    // EMPLEADOS
    // ══════════════════════════════════════════════════════════════

    public function empleados(Request $request)
    {
        $query = Empleado::with('configuracion');

        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($qb) use ($q) {
                $qb->where('nombre', 'LIKE', "%{$q}%")
                    ->orWhere('cedula', 'LIKE', "%{$q}%")
                    ->orWhere('puesto', 'LIKE', "%{$q}%");
            });
        }

        if ($request->filled('activo')) {
            $query->where('activo', $request->boolean('activo'));
        }

        if ($request->filled('departamento')) {
            $query->where('departamento', $request->departamento);
        }

        return response()->json([
            'empleados' => $query->orderBy('nombre')->get(),
        ]);
    }

    public function crearEmpleado(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:200',
            'cedula' => 'required|string|max:20|unique:empleados,cedula',
            'puesto' => 'required|string|max:100',
            'salario_base' => 'nullable|numeric|min:0',
            'tipo_contrato' => 'nullable|string|in:indefinido,temporal,servicios',
        ]);

        $empleado = Empleado::create($request->only([
            'nombre', 'cedula', 'puesto', 'departamento', 'salario_base',
            'fecha_ingreso', 'tipo_contrato', 'cuenta_banco', 'telefono', 'email',
<<<<<<< HEAD
            'notas_empleado',
=======
>>>>>>> d7dafcbe21dc386b5335b6d3b6a9f0f0f093f9cc
        ]));

        // Crear configuración por defecto
        PlanillaConfiguracion::create([
            'empleado_id' => $empleado->id,
            'tipo_salario' => 'fijo',
            'jornada_laboral' => 8.0,
            'metodo_pago' => 'quincenal',
            'formula_texto' => 'salario_base + monto_horas_extra + bonificaciones + comisiones + incentivos - ccss - impuesto_renta - rebajos - embargos - otras_deducciones + otros_ingresos',
        ]);

        return response()->json(['success' => true, 'empleado' => $empleado->load('configuracion')]);
    }

    public function actualizarEmpleado(Request $request, $id)
    {
        $empleado = Empleado::findOrFail($id);
        $empleado->update($request->only([
            'nombre', 'puesto', 'departamento', 'salario_base',
            'tipo_contrato', 'cuenta_banco', 'telefono', 'email', 'activo',
<<<<<<< HEAD
            'notas_empleado',
=======
>>>>>>> d7dafcbe21dc386b5335b6d3b6a9f0f0f093f9cc
        ]));

        return response()->json(['success' => true, 'empleado' => $empleado->fresh()->load('configuracion')]);
    }

    public function eliminarEmpleado($id)
    {
        Empleado::findOrFail($id)->delete();
        return response()->json(['success' => true]);
    }

    // ══════════════════════════════════════════════════════════════
    // CONFIGURACIÓN INDIVIDUAL POR EMPLEADO
    // ══════════════════════════════════════════════════════════════

    public function obtenerConfiguracion($empleadoId)
    {
        $config = PlanillaConfiguracion::where('empleado_id', $empleadoId)
            ->with('plantilla')
            ->first();

        if (!$config) {
            // Crear configuración por defecto
            $config = PlanillaConfiguracion::create([
                'empleado_id' => $empleadoId,
                'tipo_salario' => 'fijo',
                'jornada_laboral' => 8.0,
                'metodo_pago' => 'quincenal',
                'formula_texto' => 'salario_base + monto_horas_extra + bonificaciones + comisiones + incentivos - ccss - impuesto_renta - rebajos - embargos - otras_deducciones + otros_ingresos',
            ]);
        }

        return response()->json(['configuracion' => $config]);
    }

    public function guardarConfiguracion(Request $request, $empleadoId)
    {
        $request->validate([
            'formula_texto' => 'nullable|string|max:2000',
            'tipo_salario' => 'nullable|string|in:fijo,por_hora,por_comision,mixto',
            'jornada_laboral' => 'nullable|numeric|min:1|max:24',
            'metodo_pago' => 'nullable|string|in:diario,semanal,quincenal,mensual',
            'pago_por_hora' => 'nullable|numeric|min:0',
            'pago_diario' => 'nullable|numeric|min:0',
            'pago_semanal' => 'nullable|numeric|min:0',
            'pago_quincenal' => 'nullable|numeric|min:0',
            'pago_mensual' => 'nullable|numeric|min:0',
            'configuracion_json' => 'nullable|array',
        ]);

        // Validar fórmula si se proporciona
        if ($request->filled('formula_texto')) {
            $errors = $this->parser->validate($request->formula_texto);
            if (!empty($errors)) {
                return response()->json(['success' => false, 'errors' => $errors], 422);
            }
        }

        $config = PlanillaConfiguracion::updateOrCreate(
            ['empleado_id' => $empleadoId],
            array_merge(
                $request->only([
                    'formula_texto', 'tipo_salario', 'jornada_laboral', 'metodo_pago',
                    'pago_por_hora', 'pago_diario', 'pago_semanal', 'pago_quincenal',
                    'pago_mensual', 'configuracion_json', 'plantilla_id', 'activo',
                ]),
                $request->filled('formula_texto')
                    ? ['formula_tokens' => $this->parser->tokenize($request->formula_texto)]
                    : []
            )
        );

        // Registrar en historial
        $this->registrarHistorial($empleadoId, 'configuracion', null, $request->formula_texto, null, $config->toArray());

        return response()->json(['success' => true, 'configuracion' => $config]);
    }

    // ══════════════════════════════════════════════════════════════
    // VALIDACIÓN Y SIMULACIÓN DE FÓRMULAS
    // ══════════════════════════════════════════════════════════════

    public function validarFormula(Request $request)
    {
        $request->validate([
            'formula' => 'required|string|max:2000',
        ]);

        $errors = $this->parser->validate($request->formula);

        return response()->json([
            'valid' => empty($errors),
            'errors' => $errors,
            'tokens' => empty($errors) ? $this->parser->tokenize($request->formula) : null,
            'formato' => empty($errors) ? $this->parser->formatFormula($request->formula) : null,
        ]);
    }

    public function simularFormula(Request $request)
    {
        $request->validate([
            'formula' => 'required|string|max:2000',
            'variables' => 'required|array',
        ]);

        // Validar fórmula primero
        $errors = $this->parser->validate($request->formula);
        if (!empty($errors)) {
            return response()->json(['success' => false, 'errors' => $errors], 422);
        }

        // Agregar variables calculadas
        $variables = $request->variables;
        $salarioBase = $variables['salario_base'] ?? 0;
        $jornada = $variables['jornada_laboral'] ?? 8;
        $horasExtra = $variables['horas_extra'] ?? 0;

        // Auto-calcular valores derivados
        $salarioDiario = $salarioBase / 30;
        $pagoHora = $salarioDiario / $jornada;
        $variables['salario_diario'] = round($salarioDiario, 2);
        $variables['pago_hora'] = round($pagoHora, 2);
        $variables['monto_horas_extra'] = round($horasExtra * $pagoHora * 1.5, 2);
        $variables['monto_horas_dobles'] = round(($variables['horas_dobles'] ?? 0) * $pagoHora * 2, 2);
        $variables['monto_horas_nocturnas'] = round(($variables['horas_nocturnas'] ?? 0) * $pagoHora * 1.35, 2);
        $variables['salario_semanal'] = round($salarioDiario * 7, 2);
        $variables['salario_quincenal'] = round($salarioDiario * 15, 2);
        $variables['salario_mensual'] = round($salarioDiario * 30, 2);

        // Auto-calcular CCSS si no viene
        if (!isset($variables['ccss'])) {
            $variables['ccss'] = round($salarioBase * 0.1067, 2);
        }

        $simulacion = $this->evaluator->simulate($request->formula, $variables);

        return response()->json(['success' => true, 'simulacion' => $simulacion]);
    }

    // ══════════════════════════════════════════════════════════════
    // VARIABLES
    // ══════════════════════════════════════════════════════════════

    public function variables()
    {
        return response()->json([
            'variables' => PlanillaVariable::activas()->orderBy('tipo')->orderBy('nombre')->get(),
        ]);
    }

    public function crearVariable(Request $request)
    {
        $request->validate([
            'clave' => 'required|string|max:50|unique:planilla_variables,clave',
            'nombre' => 'required|string|max:100',
            'tipo' => 'required|string|in:ingreso,deduccion,operacion,custom',
            'formula_default' => 'nullable|string|max:1000',
        ]);

        $variable = PlanillaVariable::create(array_merge(
            $request->only(['clave', 'nombre', 'tipo', 'formula_default']),
            ['es_sistema' => false]
        ));

        return response()->json(['success' => true, 'variable' => $variable]);
    }

    public function actualizarVariable(Request $request, $id)
    {
        $variable = PlanillaVariable::findOrFail($id);

        if ($variable->es_sistema) {
            return response()->json(['success' => false, 'message' => 'No se pueden editar variables del sistema.'], 403);
        }

        $variable->update($request->only(['nombre', 'tipo', 'formula_default', 'activo']));

        return response()->json(['success' => true, 'variable' => $variable]);
    }

    public function eliminarVariable($id)
    {
        $variable = PlanillaVariable::findOrFail($id);

        if ($variable->es_sistema) {
            return response()->json(['success' => false, 'message' => 'No se pueden eliminar variables del sistema.'], 403);
        }

        $variable->delete();
        return response()->json(['success' => true]);
    }

    // ══════════════════════════════════════════════════════════════
    // PLANTILLAS
    // ══════════════════════════════════════════════════════════════

    public function plantillas()
    {
        return response()->json([
            'plantillas' => PlanillaPlantilla::with('empleados')->orderBy('nombre')->get(),
        ]);
    }

    public function crearPlantilla(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:200',
            'descripcion' => 'nullable|string|max:500',
            'formula_texto' => 'required|string|max:2000',
            'configuracion_base' => 'nullable|array',
        ]);

        $errors = $this->parser->validate($request->formula_texto);
        if (!empty($errors)) {
            return response()->json(['success' => false, 'errors' => $errors], 422);
        }

        $plantilla = PlanillaPlantilla::create(array_merge(
            $request->only(['nombre', 'descripcion', 'formula_texto', 'configuracion_base']),
            [
                'formula_tokens' => $this->parser->tokenize($request->formula_texto),
                'usuario_id' => Auth::id(),
            ]
        ));

        return response()->json(['success' => true, 'plantilla' => $plantilla]);
    }

    public function actualizarPlantilla(Request $request, $id)
    {
        $plantilla = PlanillaPlantilla::findOrFail($id);

        if ($plantilla->es_sistema) {
            return response()->json(['success' => false, 'message' => 'No se pueden editar plantillas del sistema.'], 403);
        }

        if ($request->has('formula_texto')) {
            $errors = $this->parser->validate($request->formula_texto);
            if (!empty($errors)) {
                return response()->json(['success' => false, 'errors' => $errors], 422);
            }
        }

        $plantilla->update(array_merge(
            $request->only(['nombre', 'descripcion', 'formula_texto', 'configuracion_base', 'activo']),
            $request->has('formula_texto')
                ? ['formula_tokens' => $this->parser->tokenize($request->formula_texto)]
                : []
        ));

        return response()->json(['success' => true, 'plantilla' => $plantilla]);
    }

    public function eliminarPlantilla($id)
    {
        $plantilla = PlanillaPlantilla::findOrFail($id);

        if ($plantilla->es_sistema) {
            return response()->json(['success' => false, 'message' => 'No se pueden eliminar plantillas del sistema.'], 403);
        }

        $plantilla->delete();
        return response()->json(['success' => true]);
    }

    public function asignarPlantilla(Request $request, $id)
    {
        $request->validate([
            'empleado_ids' => 'required|array',
            'empleado_ids.*' => 'integer|exists:empleados,id',
        ]);

        $plantilla = PlanillaPlantilla::findOrFail($id);

        // Sincronizar empleados
        $plantilla->empleados()->sync($request->empleado_ids);

        // Aplicar configuración de plantilla a cada empleado
        foreach ($request->empleado_ids as $empleadoId) {
            PlanillaConfiguracion::updateOrCreate(
                ['empleado_id' => $empleadoId],
                [
                    'plantilla_id' => $plantilla->id,
                    'formula_texto' => $plantilla->formula_texto,
                    'formula_tokens' => $plantilla->formula_tokens,
                    'configuracion_json' => $plantilla->configuracion_base,
                ]
            );

            $this->registrarHistorial(
                $empleadoId,
                'plantilla',
                null,
                $plantilla->formula_texto,
                null,
                ['plantilla_id' => $plantilla->id, 'plantilla_nombre' => $plantilla->nombre]
            );
        }

        return response()->json(['success' => true]);
    }

    // ══════════════════════════════════════════════════════════════
    // HISTORIAL
    // ══════════════════════════════════════════════════════════════

    public function historial($empleadoId)
    {
        $historial = PlanillaHistorial::where('empleado_id', $empleadoId)
            ->with('usuario:id,nombre')
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        return response()->json(['historial' => $historial]);
    }

    public function restaurarVersion($historialId)
    {
        $historial = PlanillaHistorial::findOrFail($historialId);

        $config = PlanillaConfiguracion::where('empleado_id', $historial->empleado_id)->first();

        if ($config && $historial->formula_anterior) {
            $oldFormula = $config->formula_texto;
            $config->update([
                'formula_texto' => $historial->formula_anterior,
                'formula_tokens' => $this->parser->tokenize($historial->formula_anterior),
            ]);

            $this->registrarHistorial(
                $historial->empleado_id,
                'formula',
                $historial->formula_anterior,
                $oldFormula,
                null,
                null,
                'Restauración de versión anterior'
            );

            return response()->json(['success' => true, 'configuracion' => $config->fresh()]);
        }

        return response()->json(['success' => false, 'message' => 'No se pudo restaurar la versión.'], 404);
    }

    // ══════════════════════════════════════════════════════════════
    // PAGOS
    // ══════════════════════════════════════════════════════════════

    public function pagos(Request $request)
    {
        $query = PlanillaPago::with('empleado');

        if ($request->filled('empleado_id')) {
            $query->where('empleado_id', $request->empleado_id);
        }

        if ($request->filled('periodo')) {
            $query->where('periodo', $request->periodo);
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        return response()->json([
            'pagos' => $query->orderByDesc('created_at')->limit(200)->get(),
        ]);
    }

    public function crearPago(Request $request)
    {
        $request->validate([
            'empleado_id' => 'required|exists:empleados,id',
            'periodo' => 'required|date',
            'salario_base' => 'required|numeric|min:0',
            'horas_extra_cantidad' => 'nullable|numeric|min:0',
            'horas_dobles_cantidad' => 'nullable|numeric|min:0',
            'horas_nocturnas_cantidad' => 'nullable|numeric|min:0',
            'jornada_laboral' => 'nullable|numeric|min:1|max:24',
            'bonificaciones' => 'nullable|numeric|min:0',
            'comisiones' => 'nullable|numeric|min:0',
            'incentivos' => 'nullable|numeric|min:0',
            'deducciones' => 'nullable|numeric|min:0',
            'rebajos' => 'nullable|numeric|min:0',
            'embargos' => 'nullable|numeric|min:0',
            'vacaciones' => 'nullable|numeric|min:0',
            'aguinaldo' => 'nullable|numeric|min:0',
            'otros_ingresos' => 'nullable|numeric|min:0',
            'otras_deducciones' => 'nullable|numeric|min:0',
        ]);

        $empleado = Empleado::findOrFail($request->empleado_id);
        $config = PlanillaConfiguracion::where('empleado_id', $empleado->id)->first();

        $salarioBase = (float) $request->salario_base;
        $jornada = (float) ($request->jornada_laboral ?? ($config->jornada_laboral ?? 8));
        $horasExtraCantidad = (float) ($request->horas_extra_cantidad ?? 0);
        $horasDoblesCantidad = (float) ($request->horas_dobles_cantidad ?? 0);
        $horasNocturnasCantidad = (float) ($request->horas_nocturnas_cantidad ?? 0);

        // Calcular valores base
        $salarioDiario = $salarioBase / 30;
        $pagoHora = $salarioDiario / $jornada;

        // Calcular montos de horas
        $montoHorasExtra = round($horasExtraCantidad * $pagoHora * 1.5, 2);
        $montoHorasDobles = round($horasDoblesCantidad * $pagoHora * 2, 2);
        $montoHorasNocturnas = round($horasNocturnasCantidad * $pagoHora * 1.35, 2);

        // CCSS
        $ccssObrero = round($salarioBase * 0.1067, 2);
        $ccssPatronal = round($salarioBase * 0.2667, 2);

        // Calcular salario neto con fórmula del empleado o por defecto
        $variables = [
            'salario_base' => $salarioBase,
            'salario_diario' => round($salarioDiario, 2),
            'pago_hora' => round($pagoHora, 2),
            'jornada_laboral' => $jornada,
            'horas_extra' => $horasExtraCantidad,
            'monto_horas_extra' => $montoHorasExtra,
            'horas_dobles' => $horasDoblesCantidad,
            'monto_horas_dobles' => $montoHorasDobles,
            'horas_nocturnas' => $horasNocturnasCantidad,
            'monto_horas_nocturnas' => $montoHorasNocturnas,
            'bonificaciones' => (float) ($request->bonificaciones ?? 0),
            'comisiones' => (float) ($request->comisiones ?? 0),
            'incentivos' => (float) ($request->incentivos ?? 0),
            'ccss' => $ccssObrero,
            'impuesto_renta' => (float) ($request->impuesto_renta ?? 0),
            'rebajos' => (float) ($request->rebajos ?? 0),
            'embargos' => (float) ($request->embargos ?? 0),
            'vacaciones' => (float) ($request->vacaciones ?? 0),
            'aguinaldo' => (float) ($request->aguinaldo ?? 0),
            'otros_ingresos' => (float) ($request->otros_ingresos ?? 0),
            'otras_deducciones' => (float) ($request->otras_deducciones ?? 0),
            'deducciones' => (float) ($request->deducciones ?? 0),
        ];

        if ($config && $config->formula_texto) {
            $salarioNeto = $this->evaluator->evaluate($config->formula_texto, $variables);
        } else {
            // Fórmula por defecto
            $salarioNeto = $salarioBase + $montoHorasExtra + $montoHorasDobles + $montoHorasNocturnas
                + $variables['bonificaciones'] + $variables['comisiones'] + $variables['incentivos']
                + $variables['vacaciones'] + $variables['aguinaldo'] + $variables['otros_ingresos']
                - $ccssObrero - $variables['impuesto_renta'] - $variables['rebajos']
                - $variables['embargos'] - $variables['otras_deducciones'];
        }

        $pago = PlanillaPago::create([
            'empleado_id' => $empleado->id,
            'periodo' => $request->periodo,
            'fecha_pago' => $request->fecha_pago ?? now()->toDateString(),
            'salario_base' => $salarioBase,
            'horas_extra_cantidad' => $horasExtraCantidad,
            'horas_extra' => $montoHorasExtra,
            'monto_horas_extra' => $montoHorasExtra,
            'horas_dobles_cantidad' => $horasDoblesCantidad,
            'horas_dobles_monto' => $montoHorasDobles,
            'horas_nocturnas_cantidad' => $horasNocturnasCantidad,
            'horas_nocturnas_monto' => $montoHorasNocturnas,
            'bonificaciones' => $variables['bonificaciones'],
            'comisiones' => $variables['comisiones'],
            'incentivos' => $variables['incentivos'],
            'ccss_patronal' => $ccssPatronal,
            'ccss_obrero' => $ccssObrero,
            'impuesto_renta' => $variables['impuesto_renta'],
            'rebajos' => $variables['rebajos'],
            'embargos' => $variables['embargos'],
            'vacaciones' => $variables['vacaciones'],
            'aguinaldo' => $variables['aguinaldo'],
            'otros_ingresos' => $variables['otros_ingresos'],
            'otras_deducciones' => $variables['otras_deducciones'],
            'deducciones' => $variables['deducciones'],
            'salario_neto' => round($salarioNeto, 2),
            'total_pagar' => round($salarioNeto, 2),
            'estado' => 'pendiente',
            'detalle_json' => $variables,
        ]);

        return response()->json(['success' => true, 'pago' => $pago->load('empleado')]);
    }

    // ══════════════════════════════════════════════════════════════
    // PROCESAMIENTO MASIVO DE NÓMINA
    // ══════════════════════════════════════════════════════════════

    public function procesarNomina(Request $request)
    {
        $request->validate([
            'periodo' => 'required|date',
            'empleado_ids' => 'nullable|array',
            'empleado_ids.*' => 'integer|exists:empleados,id',
            'fecha_pago' => 'nullable|date',
        ]);

        $query = Empleado::where('activo', true);
        if ($request->filled('empleado_ids')) {
            $query->whereIn('id', $request->empleado_ids);
        }

        $empleados = $query->get();
        $pagosCreados = 0;
        $errores = [];

        DB::beginTransaction();

        try {
            foreach ($empleados as $empleado) {
                // Verificar que no exista ya un pago para este empleado en este periodo
                $existe = PlanillaPago::where('empleado_id', $empleado->id)
                    ->where('periodo', $request->periodo)
                    ->exists();

                if ($existe) {
                    $errores[] = "Ya existe pago para {$empleado->nombre} en periodo {$request->periodo}";
                    continue;
                }

                $config = PlanillaConfiguracion::where('empleado_id', $empleado->id)->first();

                $salarioBase = (float) $empleado->salario_base;
                $jornada = $config ? (float) $config->jornada_laboral : 8.0;
                $salarioDiario = $salarioBase / 30;
                $pagoHora = $salarioDiario / $jornada;

                $variables = [
                    'salario_base' => $salarioBase,
                    'salario_diario' => round($salarioDiario, 2),
                    'pago_hora' => round($pagoHora, 2),
                    'jornada_laboral' => $jornada,
                    'horas_extra' => 0,
                    'monto_horas_extra' => 0,
                    'horas_dobles' => 0,
                    'monto_horas_dobles' => 0,
                    'horas_nocturnas' => 0,
                    'monto_horas_nocturnas' => 0,
                    'bonificaciones' => 0,
                    'comisiones' => 0,
                    'incentivos' => 0,
                    'ccss' => round($salarioBase * 0.1067, 2),
                    'impuesto_renta' => 0,
                    'rebajos' => 0,
                    'embargos' => 0,
                    'vacaciones' => 0,
                    'aguinaldo' => 0,
                    'otros_ingresos' => 0,
                    'otras_deducciones' => 0,
                    'deducciones' => 0,
                ];

                if ($config && $config->formula_texto) {
                    $salarioNeto = $this->evaluator->evaluate($config->formula_texto, $variables);
                } else {
                    $salarioNeto = $salarioBase - $variables['ccss'];
                }

                PlanillaPago::create([
                    'empleado_id' => $empleado->id,
                    'periodo' => $request->periodo,
                    'fecha_pago' => $request->fecha_pago ?? now()->toDateString(),
                    'salario_base' => $salarioBase,
                    'horas_extra_cantidad' => 0,
                    'horas_extra' => 0,
                    'monto_horas_extra' => 0,
                    'bonificaciones' => 0,
                    'comisiones' => 0,
                    'ccss_patronal' => round($salarioBase * 0.2667, 2),
                    'ccss_obrero' => $variables['ccss'],
                    'impuesto_renta' => 0,
                    'salario_neto' => round($salarioNeto, 2),
                    'total_pagar' => round($salarioNeto, 2),
                    'estado' => 'pendiente',
                    'detalle_json' => $variables,
                ]);

                $pagosCreados++;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'pagos_creados' => $pagosCreados,
                'errores' => $errores,
                'total_empleados' => $empleados->count(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error al procesar nómina: ' . $e->getMessage(),
            ], 500);
        }
    }

    // ══════════════════════════════════════════════════════════════
    // HELPERS
    // ══════════════════════════════════════════════════════════════

    private function registrarHistorial(
        int $empleadoId,
        string $tipoCambio,
        ?string $formulaAnterior,
        ?string $formulaNueva,
        ?array $configAnterior,
        ?array $configNueva,
        ?string $motivo = null
    ): void {
        PlanillaHistorial::create([
            'empleado_id' => $empleadoId,
            'usuario_id' => Auth::id(),
            'tipo_cambio' => $tipoCambio,
            'formula_anterior' => $formulaAnterior,
            'formula_nueva' => $formulaNueva,
            'configuracion_anterior' => $configAnterior,
            'configuracion_nueva' => $configNueva,
            'motivo' => $motivo,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}
