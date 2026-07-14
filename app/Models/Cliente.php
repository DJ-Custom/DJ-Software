<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Cliente extends Model
{
    use Auditable;
    protected $table = 'clientes';

    protected $fillable = [
        'nombre', 'cedula', 'empresa', 'cedula_juridica', 'telefono', 'email', 'password', 'direccion',
        'ciudad', 'pais', 'clasificacion', 'cliente_categoria_id', 'datos_fiscales', 'credito_tienda',
        'notas', 'activo', 'puntos_acumulados', 'puntos_canjeados',
        'portal_activo', 'origen', 'lat', 'lng',
    ];

    protected $hidden = ['password'];

    protected function casts(): array
    {
        return [
            'activo' => 'boolean',
            'portal_activo' => 'boolean',
            'credito_tienda' => 'decimal:2',
            'total_compras' => 'decimal:2',
        ];
    }

    public function ventas()
    {
        return $this->hasMany(Venta::class, 'cliente_id');
    }

    public function notas()
    {
        return $this->hasMany(ClienteNota::class, 'cliente_id');
    }

    public function etiquetas()
    {
        return $this->belongsToMany(Etiqueta::class, 'cliente_etiquetas', 'cliente_id', 'etiqueta_id');
    }

    public function clienteCategoria()
    {
        return $this->belongsTo(ClienteCategoria::class, 'cliente_categoria_id');
    }
}
