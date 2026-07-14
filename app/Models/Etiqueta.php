<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Etiqueta extends Model
{
    use Auditable;
    protected $table = 'etiquetas';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['nombre', 'color'];

    public function clientes()
    {
        return $this->belongsToMany(Cliente::class, 'cliente_etiquetas', 'etiqueta_id', 'cliente_id');
    }
}
