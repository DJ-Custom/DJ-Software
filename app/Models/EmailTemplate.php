<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class EmailTemplate extends Model
{
    use Auditable;
    protected $table = 'email_templates';

    protected $fillable = [
        'nombre', 'asunto', 'categoria', 'html_content', 'json_content', 'thumbnail', 'es_publico', 'usuario_id'
    ];

    public function creador()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }
}
