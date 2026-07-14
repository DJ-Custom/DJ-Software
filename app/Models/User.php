<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use App\Traits\Auditable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use Auditable;
    use HasApiTokens, Notifiable;

    protected $table = 'usuarios';

    protected $fillable = [
        'nombre', 'email', 'password', 'rol_id', 'avatar', 'activo',
        'theme_mode', 'pin_rapido', 'auto_logout_min', 'modulos_acceso',
        'secret_2fa', 'two_fa_enabled', 'ip_whitelist',
    ];

    protected $hidden = [
        'password', 'pin_rapido', 'secret_2fa', 'token_recuperacion',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'activo' => 'boolean',
            'two_fa_enabled' => 'boolean',
            'modulos_acceso' => 'array',
            'ip_whitelist' => 'array',
            'ultimo_login' => 'datetime',
            'bloqueado_hasta' => 'datetime',
        ];
    }

    public function rol()
    {
        return $this->belongsTo(Role::class, 'rol_id');
    }

    public function ventas()
    {
        return $this->hasMany(Venta::class, 'usuario_id');
    }
}
