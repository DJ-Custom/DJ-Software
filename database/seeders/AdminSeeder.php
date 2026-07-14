<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $rol = Role::firstOrCreate(
            ['nombre' => 'Administrador'],
            ['descripcion' => 'Acceso total al sistema']
        );

        User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'nombre' => 'Admin',
                'password' => bcrypt('12345678'),
                'rol_id' => $rol->id,
                'activo' => true,
                'theme_mode' => 'dark',
            ]
        );
    }
}
