<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PlanillaVariableSeeder extends Seeder
{
    public function run(): void
    {
        $variables = [
            // ── Ingresos ──
            ['clave' => 'salario_base',       'nombre' => 'Salario Base',          'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'pago_hora',           'nombre' => 'Pago por Hora',         'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'horas_ord',           'nombre' => 'Horas Ordinarias',      'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'horas_extra',         'nombre' => 'Horas Extra',           'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'horas_dobles',        'nombre' => 'Horas Dobles',          'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'horas_nocturnas',     'nombre' => 'Horas Nocturnas',       'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'bonificaciones',      'nombre' => 'Bonificaciones',        'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'comisiones',          'nombre' => 'Comisiones',            'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'incentivos',          'nombre' => 'Incentivos',            'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'dias_trabajados',     'nombre' => 'Días Trabajados',       'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'vacaciones',          'nombre' => 'Vacaciones',            'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'aguinaldo',           'nombre' => 'Aguinaldo',             'tipo' => 'ingreso',  'es_sistema' => true],
            ['clave' => 'otros_ingresos',      'nombre' => 'Otros Ingresos',        'tipo' => 'ingreso',  'es_sistema' => true],

            // ── Deducciones ──
            ['clave' => 'ccss',                'nombre' => 'CCSS',                  'tipo' => 'deduccion', 'es_sistema' => true],
            ['clave' => 'impuesto_renta',      'nombre' => 'Impuesto sobre la Renta', 'tipo' => 'deduccion', 'es_sistema' => true],
            ['clave' => 'rebajos',             'nombre' => 'Rebajos',               'tipo' => 'deduccion', 'es_sistema' => true],
            ['clave' => 'embargos',            'nombre' => 'Embargos',              'tipo' => 'deduccion', 'es_sistema' => true],
            ['clave' => 'otras_deducciones',   'nombre' => 'Otras Deducciones',     'tipo' => 'deduccion', 'es_sistema' => true],

            // ── Variables calculadas ──
            ['clave' => 'salario_diario',      'nombre' => 'Salario Diario',        'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'salario_base / 30'],
            ['clave' => 'salario_semanal',     'nombre' => 'Salario Semanal',       'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'salario_diario * 7'],
            ['clave' => 'salario_quincenal',   'nombre' => 'Salario Quincenal',     'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'salario_diario * 15'],
            ['clave' => 'salario_mensual',     'nombre' => 'Salario Mensual',       'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'salario_diario * 30'],
            ['clave' => 'monto_horas_extra',   'nombre' => 'Monto Horas Extra',     'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'horas_extra * pago_hora * 1.5'],
            ['clave' => 'monto_horas_dobles',  'nombre' => 'Monto Horas Dobles',    'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'horas_dobles * pago_hora * 2'],
            ['clave' => 'monto_horas_nocturnas','nombre' => 'Monto Horas Nocturnas', 'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'horas_nocturnas * pago_hora * 1.35'],
            ['clave' => 'total_ingresos',      'nombre' => 'Total Ingresos',        'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'salario_base + monto_horas_extra + bonificaciones + comisiones + incentivos + otros_ingresos'],
            ['clave' => 'total_deducciones',   'nombre' => 'Total Deducciones',     'tipo' => 'operacion', 'es_sistema' => true, 'formula_default' => 'ccss + impuesto_renta + rebajos + embargos + otras_deducciones'],
        ];

        foreach ($variables as $var) {
            DB::table('planilla_variables')->updateOrInsert(
                ['clave' => $var['clave']],
                array_merge($var, ['created_at' => now(), 'updated_at' => now()])
            );
        }
    }
}
