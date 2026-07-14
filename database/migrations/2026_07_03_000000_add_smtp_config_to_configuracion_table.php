<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $smtpKeys = [
            ['clave' => 'smtp_host',       'valor' => '',  'created_at' => now(), 'updated_at' => now()],
            ['clave' => 'smtp_port',       'valor' => '587', 'created_at' => now(), 'updated_at' => now()],
            ['clave' => 'smtp_username',   'valor' => '',  'created_at' => now(), 'updated_at' => now()],
            ['clave' => 'smtp_password',   'valor' => '',  'created_at' => now(), 'updated_at' => now()],
            ['clave' => 'smtp_encryption', 'valor' => 'tls', 'created_at' => now(), 'updated_at' => now()],
            ['clave' => 'smtp_activo',     'valor' => '0', 'created_at' => now(), 'updated_at' => now()],
        ];

        foreach ($smtpKeys as $row) {
            DB::table('configuracion')->updateOrInsert(
                ['clave' => $row['clave']],
                ['valor' => $row['valor'], 'created_at' => $row['created_at'], 'updated_at' => $row['updated_at']]
            );
        }
    }

    public function down(): void
    {
        DB::table('configuracion')->whereIn('clave', [
            'smtp_host', 'smtp_port', 'smtp_username', 'smtp_password', 'smtp_encryption', 'smtp_activo',
        ])->delete();
    }
};
