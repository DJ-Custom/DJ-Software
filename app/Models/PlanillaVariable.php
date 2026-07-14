<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlanillaVariable extends Model
{
    protected $table = 'planilla_variables';

    protected $fillable = [
        'clave', 'nombre', 'tipo', 'es_sistema', 'formula_default', 'activo',
    ];

    protected function casts(): array
    {
        return [
            'es_sistema' => 'boolean',
            'activo' => 'boolean',
        ];
    }

    public function scopeActivas($query)
    {
        return $query->where('activo', true);
    }

    public function scopeDelSistema($query)
    {
        return $query->where('es_sistema', true);
    }

    public function scopePersonalizadas($query)
    {
        return $query->where('es_sistema', false);
    }
}
