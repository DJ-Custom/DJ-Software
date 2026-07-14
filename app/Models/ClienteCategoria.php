<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class ClienteCategoria extends Model
{
    use Auditable;

    protected $table = 'cliente_categorias';

    protected $fillable = [
        'nombre', 'descripcion', 'color', 'icono', 'activo',
    ];

    protected function casts(): array
    {
        return [
            'activo' => 'boolean',
        ];
    }

    public function clientes()
    {
        return $this->hasMany(Cliente::class, 'cliente_categoria_id');
    }
}
