<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Role extends Model
{
    use Auditable;
    protected $table = 'roles';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['nombre', 'descripcion', 'permisos', 'activo'];

    protected function casts(): array
    {
        return ['permisos' => 'array', 'activo' => 'boolean'];
    }

    public function usuarios()
    {
        return $this->hasMany(User::class, 'rol_id');
    }
}
