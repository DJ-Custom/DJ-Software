<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Traspaso extends Model
{
    use Auditable;
    protected $table = 'traspasos';

    protected $fillable = [
        'numero_traspaso', 'ubicacion_origen_id', 'ubicacion_destino_id',
        'usuario_envio_id', 'usuario_recepcion_id', 'estado',
        'fecha_envio', 'fecha_recepcion', 'fecha_estimada',
        'transporte', 'notas', 'notas_recepcion',
    ];

    public function origen() { return $this->belongsTo(Ubicacion::class, 'ubicacion_origen_id'); }
    public function destino() { return $this->belongsTo(Ubicacion::class, 'ubicacion_destino_id'); }
    public function detalles() { return $this->hasMany(TraspasoDetalle::class, 'traspaso_id'); }
}
