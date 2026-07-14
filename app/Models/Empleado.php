<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Empleado extends Model
{
    use Auditable;

    protected $table = 'empleados';

    protected $fillable = [
        'nombre', 'cedula', 'puesto', 'departamento', 'fecha_ingreso',
        'salario_base', 'tipo_contrato', 'cuenta_banco', 'telefono',
<<<<<<< HEAD
        'email', 'notas_empleado', 'activo', 'usuario_id',
=======
        'email', 'activo', 'usuario_id',
>>>>>>> d7dafcbe21dc386b5335b6d3b6a9f0f0f093f9cc
    ];

    protected function casts(): array
    {
        return [
            'salario_base' => 'decimal:2',
            'fecha_ingreso' => 'date',
            'activo' => 'boolean',
        ];
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function configuracion()
    {
        return $this->hasOne(PlanillaConfiguracion::class, 'empleado_id');
    }

    public function pagos()
    {
        return $this->hasMany(PlanillaPago::class, 'empleado_id');
    }

    public function historial()
    {
        return $this->hasMany(PlanillaHistorial::class, 'empleado_id');
    }

    public function plantillas()
    {
        return $this->belongsToMany(PlanillaPlantilla::class, 'planilla_plantilla_empleados', 'empleado_id', 'plantilla_id');
    }
}
