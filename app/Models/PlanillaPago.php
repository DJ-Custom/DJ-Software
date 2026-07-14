<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class PlanillaPago extends Model
{
    use Auditable;

    protected $table = 'planilla_pagos';

    protected $fillable = [
        'periodo', 'fecha_pago', 'empleado_id', 'salario_base',
        'horas_extra_cantidad', 'horas_extra', 'monto_horas_extra',
        'comisiones', 'bonificaciones', 'ccss_patronal', 'ccss_obrero',
        'impuesto_renta', 'salario_neto', 'deducciones', 'total_pagar',
        'incentivos', 'rebajos', 'embargos', 'vacaciones', 'aguinaldo',
        'horas_dobles_cantidad', 'horas_dobles_monto',
        'horas_nocturnas_cantidad', 'horas_nocturnas_monto',
        'otros_ingresos', 'otras_deducciones', 'detalle_deducciones',
        'detalle_json', 'estado',
    ];

    protected function casts(): array
    {
        return [
            'periodo' => 'date',
            'fecha_pago' => 'date',
            'salario_base' => 'decimal:2',
            'horas_extra_cantidad' => 'decimal:2',
            'horas_extra' => 'decimal:2',
            'monto_horas_extra' => 'decimal:2',
            'comisiones' => 'decimal:2',
            'bonificaciones' => 'decimal:2',
            'ccss_patronal' => 'decimal:2',
            'ccss_obrero' => 'decimal:2',
            'impuesto_renta' => 'decimal:2',
            'salario_neto' => 'decimal:2',
            'deducciones' => 'decimal:2',
            'total_pagar' => 'decimal:2',
            'incentivos' => 'decimal:2',
            'rebajos' => 'decimal:2',
            'embargos' => 'decimal:2',
            'vacaciones' => 'decimal:2',
            'aguinaldo' => 'decimal:2',
            'horas_dobles_cantidad' => 'decimal:2',
            'horas_dobles_monto' => 'decimal:2',
            'horas_nocturnas_cantidad' => 'decimal:2',
            'horas_nocturnas_monto' => 'decimal:2',
            'otros_ingresos' => 'decimal:2',
            'otras_deducciones' => 'decimal:2',
            'detalle_json' => 'array',
        ];
    }

    public function empleado()
    {
        return $this->belongsTo(Empleado::class, 'empleado_id');
    }
}
