<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlanillaPlantilla extends Model
{
    protected $table = 'planilla_plantillas';

    protected $fillable = [
        'nombre', 'descripcion', 'formula_texto', 'formula_tokens',
        'configuracion_base', 'es_sistema', 'activo', 'usuario_id',
    ];

    protected function casts(): array
    {
        return [
            'formula_tokens' => 'array',
            'configuracion_base' => 'array',
            'es_sistema' => 'boolean',
            'activo' => 'boolean',
        ];
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function empleados()
    {
        return $this->belongsToMany(Empleado::class, 'planilla_plantilla_empleados', 'plantilla_id', 'empleado_id');
    }

    public function scopeActivas($query)
    {
        return $query->where('activo', true);
    }
}
