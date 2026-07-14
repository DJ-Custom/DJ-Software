<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Ubicacion extends Model
{
    use Auditable;
    protected $table = 'ubicaciones';

    protected $fillable = [
        'nombre', 'tipo', 'direccion', 'telefono', 'responsable',
        'lat', 'lng', 'activo', 'es_principal',
    ];
}
