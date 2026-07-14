<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlanillaHistorial extends Model
{
    protected $table = 'planilla_historial';

    protected $fillable = [
        'empleado_id', 'usuario_id', 'tipo_cambio', 'formula_anterior',
        'formula_nueva', 'configuracion_anterior', 'configuracion_nueva',
        'motivo', 'ip', 'user_agent',
    ];

    protected function casts(): array
    {
        return [
            'configuracion_anterior' => 'array',
            'configuracion_nueva' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function empleado()
    {
        return $this->belongsTo(Empleado::class, 'empleado_id');
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }
}
