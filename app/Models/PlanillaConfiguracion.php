<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlanillaConfiguracion extends Model
{
    protected $table = 'planilla_configuraciones';

    protected $fillable = [
        'empleado_id', 'plantilla_id', 'formula_texto', 'formula_tokens',
        'tipo_salario', 'jornada_laboral', 'pago_por_hora', 'pago_diario',
        'pago_semanal', 'pago_quincenal', 'pago_mensual', 'metodo_pago',
        'activo', 'configuracion_json',
    ];

    protected function casts(): array
    {
        return [
            'formula_tokens' => 'array',
            'configuracion_json' => 'array',
            'jornada_laboral' => 'decimal:1',
            'pago_por_hora' => 'decimal:2',
            'pago_diario' => 'decimal:2',
            'pago_semanal' => 'decimal:2',
            'pago_quincenal' => 'decimal:2',
            'pago_mensual' => 'decimal:2',
            'activo' => 'boolean',
        ];
    }

    public function empleado()
    {
        return $this->belongsTo(Empleado::class, 'empleado_id');
    }

    public function plantilla()
    {
        return $this->belongsTo(PlanillaPlantilla::class, 'plantilla_id');
    }
}
