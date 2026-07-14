<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ──────────────────────────────────────────────────────────
        // 1. Variables del sistema y personalizadas
        // ──────────────────────────────────────────────────────────
        Schema::create('planilla_variables', function (Blueprint $table) {
            $table->id();
            $table->string('clave')->unique();
            $table->string('nombre');
            $table->enum('tipo', ['ingreso', 'deduccion', 'operacion', 'custom'])->default('custom');
            $table->boolean('es_sistema')->default(false);
            $table->text('formula_default')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        // ──────────────────────────────────────────────────────────
        // 2. Plantillas reutilizables de cálculo
        // ──────────────────────────────────────────────────────────
        Schema::create('planilla_plantillas', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->text('formula_texto');
            $table->json('formula_tokens')->nullable();
            $table->json('configuracion_base')->nullable();
            $table->boolean('es_sistema')->default(false);
            $table->boolean('activo')->default(true);
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        // ──────────────────────────────────────────────────────────
        // 3. Configuración individual por empleado
        // ──────────────────────────────────────────────────────────
        Schema::create('planilla_configuraciones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empleado_id')->constrained('empleados')->cascadeOnDelete();
            $table->foreignId('plantilla_id')->nullable()->constrained('planilla_plantillas')->nullOnDelete();
            $table->text('formula_texto')->nullable();
            $table->json('formula_tokens')->nullable();
            $table->enum('tipo_salario', ['fijo', 'por_hora', 'por_comision', 'mixto'])->default('fijo');
            $table->decimal('jornada_laboral', 4, 1)->default(8.0);
            $table->decimal('pago_por_hora', 12, 2)->nullable();
            $table->decimal('pago_diario', 12, 2)->nullable();
            $table->decimal('pago_semanal', 12, 2)->nullable();
            $table->decimal('pago_quincenal', 12, 2)->nullable();
            $table->decimal('pago_mensual', 12, 2)->nullable();
            $table->enum('metodo_pago', ['diario', 'semanal', 'quincenal', 'mensual'])->default('quincenal');
            $table->boolean('activo')->default(true);
            $table->json('configuracion_json')->nullable();
            $table->timestamps();

            $table->unique('empleado_id');
        });

        // ──────────────────────────────────────────────────────────
        // 4. Historial de cambios (auditoría de fórmulas)
        // ──────────────────────────────────────────────────────────
        Schema::create('planilla_historial', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empleado_id')->constrained('empleados')->cascadeOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->enum('tipo_cambio', ['formula', 'configuracion', 'plantilla']);
            $table->text('formula_anterior')->nullable();
            $table->text('formula_nueva')->nullable();
            $table->json('configuracion_anterior')->nullable();
            $table->json('configuracion_nueva')->nullable();
            $table->text('motivo')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent', 500)->nullable();
            $table->timestamps();

            $table->index(['empleado_id', 'created_at']);
        });

        // ──────────────────────────────────────────────────────────
        // 5. Pivot plantilla ↔ empleado
        // ──────────────────────────────────────────────────────────
        Schema::create('planilla_plantilla_empleados', function (Blueprint $table) {
            $table->foreignId('plantilla_id')->constrained('planilla_plantillas')->cascadeOnDelete();
            $table->foreignId('empleado_id')->constrained('empleados')->cascadeOnDelete();
            $table->primary(['plantilla_id', 'empleado_id']);
        });

        // ──────────────────────────────────────────────────────────
        // 6. Extender tabla planilla_pagos
        // ──────────────────────────────────────────────────────────
        Schema::table('planilla_pagos', function (Blueprint $table) {
            $table->decimal('bonificaciones', 12, 2)->default(0)->after('comisiones');
            $table->decimal('ccss_patronal', 12, 2)->default(0)->after('bonificaciones');
            $table->decimal('ccss_obrero', 12, 2)->default(0)->after('ccss_patronal');
            $table->decimal('impuesto_renta', 12, 2)->default(0)->after('ccss_obrero');
            $table->decimal('salario_neto', 12, 2)->default(0)->after('impuesto_renta');
            $table->decimal('incentivos', 12, 2)->default(0)->after('salario_neto');
            $table->decimal('rebajos', 12, 2)->default(0)->after('incentivos');
            $table->decimal('embargos', 12, 2)->default(0)->after('rebajos');
            $table->decimal('vacaciones', 12, 2)->default(0)->after('embargos');
            $table->decimal('aguinaldo', 12, 2)->default(0)->after('vacaciones');
            $table->decimal('horas_dobles_cantidad', 10, 2)->default(0)->after('aguinaldo');
            $table->decimal('horas_dobles_monto', 12, 2)->default(0)->after('horas_dobles_cantidad');
            $table->decimal('horas_nocturnas_cantidad', 10, 2)->default(0)->after('horas_dobles_monto');
            $table->decimal('horas_nocturnas_monto', 12, 2)->default(0)->after('horas_nocturnas_cantidad');
            $table->decimal('otros_ingresos', 12, 2)->default(0)->after('horas_nocturnas_monto');
            $table->decimal('otras_deducciones', 12, 2)->default(0)->after('otros_ingresos');
            $table->json('detalle_json')->nullable()->after('otras_deducciones');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('planilla_plantilla_empleados');
        Schema::dropIfExists('planilla_historial');
        Schema::dropIfExists('planilla_configuraciones');
        Schema::dropIfExists('planilla_plantillas');
        Schema::dropIfExists('planilla_variables');

        Schema::table('planilla_pagos', function (Blueprint $table) {
            $table->dropColumn([
                'bonificaciones', 'ccss_patronal', 'ccss_obrero', 'impuesto_renta',
                'salario_neto', 'incentivos', 'rebajos', 'embargos', 'vacaciones',
                'aguinaldo', 'horas_dobles_cantidad', 'horas_dobles_monto',
                'horas_nocturnas_cantidad', 'horas_nocturnas_monto',
                'otros_ingresos', 'otras_deducciones', 'detalle_json',
            ]);
        });
    }
};
