<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('productividad_sesiones', function (Blueprint $table) {
            $table->unsignedInteger('tiempo_activo')->default(0)->after('ultima_actividad')
                ->comment('Accumulated active time in seconds');
            $table->boolean('en_pausa')->default(false)->after('tiempo_activo')
                ->comment('Whether the session is currently paused');
            $table->string('tab_id', 36)->nullable()->after('en_pausa')
                ->comment('Unique browser tab identifier');
        });
    }

    public function down(): void
    {
        Schema::table('productividad_sesiones', function (Blueprint $table) {
            $table->dropColumn(['tiempo_activo', 'en_pausa', 'tab_id']);
        });
    }
};
