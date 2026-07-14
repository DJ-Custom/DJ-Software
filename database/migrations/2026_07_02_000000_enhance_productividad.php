<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('productividad_sesiones', function (Blueprint $table) {
            $table->timestamp('ultima_actividad')->nullable()->after('fin_sesion');
        });

        Schema::create('productividad_resumen', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->date('fecha');
            $table->enum('periodo', ['dia', 'semana', 'mes', 'historico']);
            $table->unsignedInteger('total_minutos')->default(0);
            $table->unsignedInteger('total_sesiones')->default(0);
            $table->decimal('ventas_generadas', 12, 2)->default(0);
            $table->unsignedInteger('cantidad_ventas')->default(0);
            $table->timestamps();

            $table->unique(['usuario_id', 'fecha', 'periodo']);
            $table->index(['fecha', 'periodo']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('productividad_resumen');

        Schema::table('productividad_sesiones', function (Blueprint $table) {
            $table->dropColumn('ultima_actividad');
        });
    }
};
