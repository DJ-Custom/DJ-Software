<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ──────────────────────────────────────────────────────────
        // 1. Laravel defaults
        // ──────────────────────────────────────────────────────────
        Schema::create('cache', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->mediumText('value');
            $table->bigInteger('expiration')->index();
        });

        Schema::create('cache_locks', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->string('owner');
            $table->bigInteger('expiration')->index();
        });

        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('queue')->index();
            $table->longText('payload');
            $table->unsignedSmallInteger('attempts');
            $table->unsignedInteger('reserved_at')->nullable();
            $table->unsignedInteger('available_at');
            $table->unsignedInteger('created_at');
        });

        Schema::create('job_batches', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('name');
            $table->integer('total_jobs');
            $table->integer('pending_jobs');
            $table->integer('failed_jobs');
            $table->longText('failed_job_ids');
            $table->mediumText('options')->nullable();
            $table->integer('cancelled_at')->nullable();
            $table->integer('created_at');
            $table->integer('finished_at')->nullable();
        });

        Schema::create('failed_jobs', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->string('connection');
            $table->string('queue');
            $table->longText('payload');
            $table->longText('exception');
            $table->timestamp('failed_at')->useCurrent();
            $table->index(['connection', 'queue', 'failed_at']);
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });

        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->morphs('tokenable');
            $table->text('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable()->index();
            $table->timestamps();
        });

        // ──────────────────────────────────────────────────────────
        // 2. ERP — tablas base sin dependencias
        // ──────────────────────────────────────────────────────────
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('descripcion')->nullable();
            $table->json('permisos')->nullable();
            $table->boolean('activo')->default(true);  // migración: add_activo_to_roles_table
            $table->timestamps();
        });

        Schema::create('permisos', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('nombre');
            $table->string('descripcion')->nullable();
            $table->timestamps();
        });

        Schema::create('categorias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('descripcion')->nullable();
            $table->string('color')->nullable();
            $table->string('icono')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();  // migración: add_timestamps_to_categorias_table
        });

        Schema::create('etiquetas', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('color')->nullable();
            $table->timestamps();
        });

        Schema::create('ubicaciones', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('tipo')->nullable();
            $table->text('direccion')->nullable();
            $table->string('telefono')->nullable();
            $table->string('responsable')->nullable();
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->boolean('activo')->default(true);
            $table->boolean('es_principal')->default(false);
            $table->timestamps();
        });

        Schema::create('configuracion', function (Blueprint $table) {
            $table->id();
            $table->string('clave')->unique();
            $table->text('valor')->nullable();
            $table->timestamps();
        });

        Schema::create('cliente_categorias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('descripcion')->nullable();
            $table->string('color', 20)->nullable()->default('#3b82f6');
            $table->string('icono')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('listas_precios', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100);
            $table->text('descripcion')->nullable();
            $table->string('tipo')->default('porcentaje');
            $table->decimal('valor', 8, 2)->default(0);
            $table->decimal('descuento_porcentaje', 5, 2)->default(0);  // migración: add_descuento_to_listas_precios
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('cuentas_contables', function (Blueprint $table) {
            $table->id();
            $table->string('codigo')->unique();
            $table->string('nombre');
            $table->string('tipo');
            $table->unsignedBigInteger('cuenta_padre_id')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('crm_etapas', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('color', 7)->default('#3b82f6');
            $table->integer('orden')->default(0);
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('ticket_configuracion', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->default('default');
            $table->integer('ancho_mm')->default(80);
            $table->string('fuente', 100)->default('Courier New');
            $table->integer('fuente_size')->default(12);
            $table->string('logo_path')->nullable();
            $table->integer('logo_x')->default(0);
            $table->integer('logo_y')->default(0);
            $table->integer('logo_width')->default(200);
            $table->boolean('mostrar_logo')->default(true);
            $table->boolean('mostrar_nombre_negocio')->default(true);
            $table->boolean('mostrar_direccion')->default(true);
            $table->boolean('mostrar_telefono')->default(true);
            $table->boolean('mostrar_cedula')->default(true);
            $table->boolean('mostrar_vendedor')->default(true);
            $table->boolean('mostrar_cliente')->default(true);
            $table->boolean('mostrar_fecha')->default(true);
            $table->boolean('mostrar_detalle_impuesto')->default(true);
            $table->boolean('mostrar_descuento')->default(true);
            $table->boolean('mostrar_metodo_pago')->default(true);
            $table->boolean('mostrar_codigo_producto')->default(false);
            $table->boolean('mostrar_sinpe_info')->default(true);
            $table->text('header_text')->nullable();
            $table->text('footer_text')->nullable();
            $table->json('estilos_custom')->nullable();
            $table->string('color_fondo', 7)->default('#ffffff');
            $table->string('color_texto', 7)->default('#000000');
            $table->string('color_acento', 7)->default('#000000');
            $table->integer('padding_general')->default(10);
            $table->integer('borde_redondeado')->default(0);
            $table->boolean('mostrar_separadores')->default(true);
            $table->string('formato_moneda', 10)->default('₡');
            $table->json('elementos_orden')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        // cotizacion_configuracion — estado final con todas las columnas adicionales
        Schema::create('cotizacion_configuracion', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->default('default');
            $table->integer('ancho_mm')->default(80);
            $table->string('tamano_papel', 20)->default('A4');
            $table->string('orientacion', 20)->default('portrait');
            $table->string('estilo_layout', 30)->default('moderno');
            $table->string('fuente', 100)->default('Courier New');
            $table->integer('fuente_size')->default(12);
            $table->string('logo_path')->nullable();
            $table->integer('logo_x')->default(0);
            $table->integer('logo_y')->default(0);
            $table->integer('logo_width')->default(200);
            $table->boolean('mostrar_logo')->default(true);
            $table->boolean('mostrar_nombre_negocio')->default(true);
            $table->boolean('mostrar_direccion')->default(true);
            $table->boolean('mostrar_telefono')->default(true);
            $table->boolean('mostrar_cedula')->default(true);
            $table->boolean('mostrar_vendedor')->default(true);
            $table->boolean('mostrar_cliente')->default(true);
            $table->boolean('mostrar_fecha')->default(true);
            $table->boolean('mostrar_fecha_vencimiento')->default(true);
            $table->boolean('mostrar_detalle_impuesto')->default(true);
            $table->boolean('mostrar_descuento')->default(true);
            $table->boolean('mostrar_condiciones')->default(true);
            $table->boolean('mostrar_notas')->default(true);
            $table->boolean('mostrar_codigo_producto')->default(false);
            $table->boolean('mostrar_validez')->default(true);
            $table->boolean('mostrar_subtitulo')->default(true);
            $table->string('subtitulo_text', 255)->default('Cotización Profesional');
            $table->boolean('mostrar_lineas_firma')->default(true);
            $table->string('texto_firma_cliente', 100)->default('Firma del Cliente');
            $table->string('texto_firma_empresa', 100)->default('Firma Autorizada');
            $table->boolean('mostrar_marca_agua')->default(false);
            $table->string('marca_agua_texto', 100)->default('COTIZACIÓN');
            $table->boolean('mostrar_info_bancaria')->default(false);
            $table->text('info_bancaria')->nullable();
            $table->boolean('mostrar_totales_desglosados')->default(true);
            $table->boolean('mostrar_numero_pagina')->default(false);
            $table->text('header_text')->nullable();
            $table->text('footer_text')->nullable();
            $table->text('condiciones_default')->nullable();
            $table->text('notas_default')->nullable();
            $table->text('texto_terminos')->nullable();
            $table->json('estilos_custom')->nullable();
            $table->string('color_fondo', 7)->default('#ffffff');
            $table->string('color_texto', 7)->default('#000000');
            $table->string('color_acento', 7)->default('#000000');
            $table->string('color_encabezado', 7)->default('#01234e');
            $table->string('color_borde', 7)->default('#01234e');
            $table->integer('padding_general')->default(10);
            $table->integer('borde_redondeado')->default(0);
            $table->boolean('mostrar_separadores')->default(true);
            $table->string('formato_moneda', 10)->default('₡');
            $table->json('elementos_orden')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('formularios', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100);
            $table->text('descripcion')->nullable();
            $table->json('campos')->nullable();
            $table->json('campos_json')->nullable();
            $table->boolean('activo')->default(true);
            $table->string('slug')->nullable()->unique();
            $table->timestamps();
        });

        // ──────────────────────────────────────────────────────────
        // 3. ERP — tablas con dependencias simples
        // ──────────────────────────────────────────────────────────
        Schema::create('usuarios', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('email')->unique();
            $table->string('password');
            $table->foreignId('rol_id')->nullable()->constrained('roles')->nullOnDelete();
            $table->string('avatar')->nullable();
            $table->boolean('activo')->default(true);
            $table->string('theme_mode')->default('light');
            $table->string('pin_rapido')->nullable();
            $table->integer('auto_logout_min')->nullable();
            $table->json('modulos_acceso')->nullable();
            $table->string('secret_2fa')->nullable();
            $table->boolean('two_fa_enabled')->default(false);
            $table->json('ip_whitelist')->nullable();
            $table->integer('intentos_fallidos')->default(0);
            $table->timestamp('bloqueado_hasta')->nullable();
            $table->timestamp('ultimo_login')->nullable();
            $table->string('token_recuperacion')->nullable();
            $table->timestamps();
        });

        // clientes — estado final con todas las columnas y con las correcciones aplicadas
        Schema::create('clientes', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('cedula')->nullable();
            $table->foreignId('cliente_categoria_id')->nullable()->constrained('cliente_categorias')->nullOnDelete(); // migración: create_cliente_categorias_table
            $table->string('empresa', 150)->nullable();           // migración: add_empresa_cedula_juridica_to_clientes
            $table->string('cedula_juridica', 50)->nullable();    // migración: add_empresa_cedula_juridica_to_clientes
            $table->string('telefono')->nullable();
            $table->string('email')->nullable();
            $table->string('password')->nullable();
            $table->string('direccion', 255)->nullable();         // migración: fix_clientes_credito_tienda_nullable
            $table->string('ciudad', 100)->nullable();            // migración: fix_clientes_credito_tienda_nullable
            $table->string('pais', 100)->nullable();              // migración: fix_clientes_credito_tienda_nullable
            $table->string('clasificacion', 50)->nullable()->default('regular'); // migración: fix_clientes_credito_tienda_nullable
            $table->string('datos_fiscales', 500)->nullable();    // migración: fix_clientes_credito_tienda_nullable
            $table->decimal('credito_tienda', 12, 2)->nullable()->default(0); // migración: fix_clientes_credito_tienda_nullable
            $table->string('notas', 500)->nullable();             // migración: fix_clientes_credito_tienda_nullable
            $table->boolean('activo')->default(true);
            $table->integer('puntos_acumulados')->default(0);
            $table->integer('puntos_canjeados')->default(0);
            $table->boolean('portal_activo')->default(false);
            $table->string('origen')->nullable();
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->decimal('total_compras', 12, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('proveedores', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('contacto_nombre')->nullable();
            $table->string('empresa')->nullable();
            $table->string('telefono')->nullable();
            $table->string('email')->nullable();
            $table->text('direccion')->nullable();
            $table->text('notas')->nullable();
            $table->text('notas_internas')->nullable();
            $table->integer('calificacion')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('productos', function (Blueprint $table) {
            $table->id();
            $table->string('codigo')->nullable()->unique();
            $table->string('codigo_barras')->nullable();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->foreignId('categoria_id')->nullable()->constrained('categorias')->nullOnDelete();
            $table->foreignId('proveedor_id')->nullable()->constrained('proveedores')->nullOnDelete();
            $table->decimal('precio_compra', 12, 2)->default(0);
            $table->decimal('precio_venta', 12, 2)->default(0);
            $table->integer('stock')->default(0);
            $table->integer('stock_minimo')->default(0);
            $table->integer('stock_maximo')->nullable();
            $table->string('unidad')->nullable();
            $table->string('imagen')->nullable();
            $table->decimal('impuesto', 5, 2)->default(0);
            $table->decimal('margen_ganancia', 5, 2)->nullable();
            $table->decimal('peso', 8, 2)->nullable();
            $table->decimal('costo_envio', 12, 2)->nullable();
            $table->decimal('costo_marketing', 12, 2)->nullable();
            $table->decimal('costo_logistica', 12, 2)->nullable();
            $table->boolean('visible_web')->default(false);
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('combos', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->decimal('precio_combo', 12, 2);
            $table->decimal('precio_regular', 12, 2)->default(0);
            $table->decimal('precio_normal', 12, 2)->default(0);
            $table->decimal('ahorro_total', 12, 2)->default(0);
            $table->date('fecha_inicio')->nullable();
            $table->date('fecha_fin')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('promociones', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->text('descripcion')->nullable();
            $table->string('tipo_descuento');
            $table->decimal('valor_descuento', 12, 2);
            $table->string('aplica_a')->default('todos');
            $table->unsignedBigInteger('aplica_id')->nullable();
            $table->decimal('compra_minima', 12, 2)->default(0);
            $table->date('fecha_inicio')->nullable();
            $table->date('fecha_fin')->nullable();
            $table->boolean('activo')->default(true);
            $table->boolean('no_combinable')->default(false);
            $table->integer('limite_usos')->default(0);
            $table->json('etiquetas_clientes')->nullable();
            $table->timestamps();
        });

        Schema::create('cupones', function (Blueprint $table) {
            $table->id();
            $table->string('codigo')->unique();
            $table->string('tipo_descuento');
            $table->decimal('valor_descuento', 12, 2);
            $table->decimal('compra_minima', 12, 2)->default(0);
            $table->integer('usos_maximos')->nullable();
            $table->integer('limite_por_cliente')->nullable();
            $table->integer('usos_actuales')->default(0);
            $table->date('fecha_inicio')->nullable();
            $table->date('fecha_fin')->nullable();
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('cajas', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->foreignId('ubicacion_id')->nullable()->constrained('ubicaciones')->nullOnDelete();

            $table->unsignedBigInteger('usuario_id')->nullable()->index();
            $table->foreign('usuario_id')
                ->references('id')
                ->on('usuarios')
                ->onDelete('set null')
                ->onUpdate('cascade');
            
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('campanas_email', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('asunto');
            $table->text('contenido_html')->nullable();
            $table->string('estado')->default('borrador');
            $table->integer('enviados')->default(0);
            $table->integer('abiertos')->default(0);
            $table->integer('clicks')->default(0);
            $table->timestamp('enviado_at')->nullable();
            $table->timestamps();
        });

        Schema::create('email_campaigns', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('asunto');
            $table->longText('html_content')->nullable();
            $table->longText('json_content')->nullable();
            $table->string('thumbnail')->nullable();
            $table->string('estado')->default('borrador');
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamp('programada_para')->nullable();
            $table->timestamp('enviada_en')->nullable();
            $table->integer('total_recipients')->default(0);
            $table->integer('total_enviados')->default(0);
            $table->integer('total_abiertos')->default(0);
            $table->integer('total_clicks')->default(0);
            $table->integer('total_rebotes')->default(0);
            $table->timestamps();
        });

        Schema::create('plantillas_email', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('asunto')->nullable();
            $table->longText('contenido_html');
            $table->longText('contenido_json')->nullable();
            $table->string('categoria', 50)->nullable();
            $table->boolean('activo')->default(true);
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('email_templates', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('asunto')->nullable();
            $table->string('categoria', 50)->nullable();
            $table->longText('html_content')->nullable();
            $table->longText('json_content')->nullable();
            $table->string('thumbnail')->nullable();
            $table->boolean('es_publico')->default(false);
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('notificaciones', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('mensaje');
            $table->string('color')->default('#ef4444');
            $table->string('icono')->default('fas fa-bell');
            $table->string('tipo')->default('informativa');
            $table->string('prioridad')->default('normal');
            $table->foreignId('creador_id')->constrained('usuarios')->cascadeOnDelete();
            $table->boolean('global')->default(false);
            $table->timestamp('enviada_en')->useCurrent();
            $table->timestamps();
        });

        Schema::create('chats', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('descripcion')->nullable();
            $table->foreignId('creador_id')->constrained('usuarios')->cascadeOnDelete();
            $table->string('estado')->default('abierto');
            $table->foreignId('cerrado_por')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamp('cerrado_en')->nullable();
            $table->timestamps();
        });

        Schema::create('presupuestos', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('periodo', 20);
            $table->date('fecha_inicio');
            $table->date('fecha_fin');
            $table->decimal('monto_total', 14, 2)->default(0);
            $table->decimal('monto_ejecutado', 14, 2)->default(0);
            $table->string('estado')->default('activo');
            $table->text('notas')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('asientos_contables', function (Blueprint $table) {
            $table->id();
            $table->string('numero')->unique();
            $table->date('fecha');
            $table->text('descripcion')->nullable();
            $table->string('referencia_tipo')->nullable();
            $table->unsignedBigInteger('referencia_id')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('empleados', function (Blueprint $table) {
            $table->id();
            $table->string('nombre');
            $table->string('cedula')->nullable();
            $table->string('puesto')->nullable();
            $table->string('departamento')->nullable();
            $table->date('fecha_ingreso')->nullable();
            $table->decimal('salario_base', 12, 2)->default(0);
            $table->string('tipo_contrato')->default('indefinido');
            $table->string('cuenta_banco')->nullable();
            $table->string('telefono')->nullable();
            $table->string('email')->nullable();
            $table->boolean('activo')->default(true);
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        // ──────────────────────────────────────────────────────────
        // 4. ERP — pivots y tablas de detalle
        // ──────────────────────────────────────────────────────────
        Schema::create('rol_permisos', function (Blueprint $table) {
            $table->foreignId('rol_id')->constrained('roles')->cascadeOnDelete();
            $table->foreignId('permiso_id')->constrained('permisos')->cascadeOnDelete();
            $table->primary(['rol_id', 'permiso_id']);
        });

        Schema::create('producto_variantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->string('nombre');
            $table->string('tipo')->nullable();
            $table->string('valor')->nullable();
            $table->string('sku')->nullable();
            $table->decimal('precio_adicional', 12, 2)->default(0);
            $table->integer('stock')->default(0);
            $table->boolean('activo')->default(true);
            $table->timestamps();
        });

        Schema::create('producto_imagenes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->string('ruta');
            $table->boolean('es_principal')->default(false);
            $table->integer('orden')->default(0);
            $table->timestamps();
        });

        Schema::create('cliente_notas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->constrained('clientes')->cascadeOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->string('tipo')->nullable();
            $table->text('contenido');
            $table->timestamps();
        });

        Schema::create('cliente_etiquetas', function (Blueprint $table) {
            $table->foreignId('cliente_id')->constrained('clientes')->cascadeOnDelete();
            $table->foreignId('etiqueta_id')->constrained('etiquetas')->cascadeOnDelete();
            $table->primary(['cliente_id', 'etiqueta_id']);
        });

        Schema::create('proveedor_productos', function (Blueprint $table) {
            $table->foreignId('proveedor_id')->constrained('proveedores')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->primary(['proveedor_id', 'producto_id']);
        });

        // ventas — con cotizacion_id ya incluido (migración: add_cotizacion_id_to_ventas)
        Schema::create('ventas', function (Blueprint $table) {
            $table->id();
            $table->string('numero_factura')->nullable()->unique();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->string('nombre_factura')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('descuento_total', 12, 2)->default(0);
            $table->decimal('impuesto_total', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->string('metodo_pago')->nullable();
            $table->decimal('monto_efectivo', 12, 2)->nullable();
            $table->decimal('monto_tarjeta', 12, 2)->nullable();
            $table->decimal('monto_sinpe', 12, 2)->nullable();
            $table->string('referencia_sinpe')->nullable();
            $table->string('comprobante_sinpe')->nullable();
            $table->decimal('dinero_recibido', 12, 2)->nullable();
            $table->decimal('cambio', 12, 2)->nullable();
            $table->string('estado')->default('completada');
            $table->unsignedBigInteger('cotizacion_id')->nullable();  // migración: add_cotizacion_id_to_ventas
            $table->string('canal')->nullable();
            $table->unsignedBigInteger('ubicacion_id')->nullable();
            $table->text('notas')->nullable();
            $table->unsignedBigInteger('cancelada_por')->nullable();
            $table->text('motivo_cancelacion')->nullable();
            $table->unsignedBigInteger('cupon_id')->nullable();
            $table->decimal('descuento_cupon', 12, 2)->nullable();
            $table->string('ip_compra')->nullable();
            $table->decimal('latitud', 10, 7)->nullable();
            $table->decimal('longitud', 10, 7)->nullable();
            $table->timestamps();
        });

        Schema::create('venta_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('venta_id')->constrained('ventas')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('descuento', 12, 2)->default(0);
            $table->decimal('impuesto', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->unsignedBigInteger('combo_id')->nullable();
            $table->timestamps();
        });

        Schema::create('venta_ubicacion', function (Blueprint $table) {
            $table->id();
            $table->foreignId('venta_id')->constrained('ventas')->cascadeOnDelete();
            $table->foreignId('ubicacion_id')->constrained('ubicaciones')->cascadeOnDelete();
            $table->timestamps();
        });

        Schema::create('devoluciones', function (Blueprint $table) {
            $table->id();
            $table->string('numero_devolucion')->nullable()->unique();
            $table->foreignId('venta_id')->constrained('ventas')->cascadeOnDelete();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->unsignedBigInteger('aprobado_por')->nullable();
            $table->string('tipo')->nullable();
            $table->string('tipo_reembolso')->nullable();
            $table->decimal('monto_total', 12, 2)->default(0);
            $table->text('motivo')->nullable();
            $table->string('estado')->default('pendiente');
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('devolucion_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('devolucion_id')->constrained('devoluciones')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->string('estado_producto')->nullable();
            $table->timestamps();
        });

        Schema::create('notas_credito', function (Blueprint $table) {
            $table->id();
            $table->string('numero_nota')->nullable()->unique();
            $table->foreignId('venta_id')->nullable()->constrained('ventas')->nullOnDelete();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->string('tipo')->nullable();
            $table->string('tipo_credito')->nullable();
            $table->decimal('monto_total', 12, 2)->default(0);
            $table->decimal('saldo_restante', 12, 2)->default(0);
            $table->text('motivo')->nullable();
            $table->string('estado')->default('activa');
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('nota_credito_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('nota_credito_id')->constrained('notas_credito')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->boolean('devolver_inventario')->default(false);
            $table->string('estado_producto')->nullable();
            $table->timestamps();
        });

        Schema::create('nota_credito_usos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('nota_credito_id')->constrained('notas_credito')->cascadeOnDelete();
            $table->foreignId('venta_id')->nullable()->constrained('ventas')->nullOnDelete();
            $table->decimal('monto_usado', 12, 2);
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->text('concepto')->nullable();
            $table->timestamps();
        });

        Schema::create('compras', function (Blueprint $table) {
            $table->id();
            $table->string('numero_compra')->nullable()->unique();
            $table->foreignId('proveedor_id')->nullable()->constrained('proveedores')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('impuesto_total', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->string('estado')->default('pendiente');
            $table->date('fecha_compra')->nullable();
            $table->date('fecha_entrega')->nullable();
            $table->string('factura_proveedor')->nullable();
            $table->string('archivo_factura')->nullable();
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('compra_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('compra_id')->constrained('compras')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('traspasos', function (Blueprint $table) {
            $table->id();
            $table->string('numero_traspaso')->nullable()->unique();
            $table->foreignId('ubicacion_origen_id')->nullable()->constrained('ubicaciones')->nullOnDelete();
            $table->foreignId('ubicacion_destino_id')->nullable()->constrained('ubicaciones')->nullOnDelete();
            $table->unsignedBigInteger('usuario_envio_id')->nullable();
            $table->unsignedBigInteger('usuario_recepcion_id')->nullable();
            $table->string('estado')->default('pendiente');
            $table->timestamp('fecha_envio')->nullable();
            $table->timestamp('fecha_recepcion')->nullable();
            $table->timestamp('fecha_estimada')->nullable();
            $table->string('transporte')->nullable();
            $table->text('notas')->nullable();
            $table->text('notas_recepcion')->nullable();
            $table->timestamps();
        });

        Schema::create('traspaso_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('traspaso_id')->constrained('traspasos')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad_enviada')->default(0);
            $table->integer('cantidad_recibida')->default(0);
            $table->integer('diferencia')->default(0);
            $table->text('notas_diferencia')->nullable();
            $table->timestamps();
        });

        // cotizaciones — con campos de aprobación ya incluidos (migraciones: add_aprobacion_to_cotizaciones)
        Schema::create('cotizaciones', function (Blueprint $table) {
            $table->id();
            $table->string('numero_cotizacion')->nullable()->unique();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('descuento_total', 12, 2)->default(0);
            $table->decimal('impuesto_total', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->string('estado')->default('borrador');
            $table->string('estado_aprobacion', 20)->nullable();  // migración: add_aprobacion_to_cotizaciones
            $table->text('motivo_rechazo')->nullable();           // migración: add_aprobacion_to_cotizaciones
            $table->unsignedBigInteger('aprobado_por')->nullable(); // migración: add_aprobacion_to_cotizaciones
            $table->timestamp('aprobado_en')->nullable();         // migración: add_aprobacion_to_cotizaciones
            $table->date('fecha_vencimiento')->nullable();
            $table->text('condiciones')->nullable();
            $table->text('notas')->nullable();
            $table->unsignedBigInteger('venta_id')->nullable();
            $table->unsignedBigInteger('pedido_id')->nullable();
            $table->timestamps();
        });

        Schema::create('cotizacion_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cotizacion_id')->constrained('cotizaciones')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('descuento', 12, 2)->default(0);
            $table->decimal('impuesto', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('pedidos', function (Blueprint $table) {
            $table->id();
            $table->string('numero_pedido')->nullable()->unique();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->unsignedBigInteger('cotizacion_id')->nullable();
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('descuento_total', 12, 2)->default(0);
            $table->decimal('impuesto_total', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->decimal('monto_adelanto', 12, 2)->default(0);
            $table->decimal('monto_pendiente', 12, 2)->default(0);
            $table->string('estado')->default('pendiente');
            $table->string('tipo_entrega')->nullable();
            $table->text('direccion_entrega')->nullable();
            $table->date('fecha_entrega_estimada')->nullable();
            $table->date('fecha_entrega_real')->nullable();
            $table->boolean('reservar_inventario')->default(false);
            $table->text('notas')->nullable();
            $table->unsignedBigInteger('venta_id')->nullable();
            $table->timestamps();
        });

        Schema::create('pedido_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pedido_id')->constrained('pedidos')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->decimal('precio_unitario', 12, 2)->default(0);
            $table->decimal('descuento', 12, 2)->default(0);
            $table->decimal('impuesto', 12, 2)->default(0);
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->boolean('reservado')->default(false);
            $table->timestamps();
        });

        Schema::create('pedido_pagos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pedido_id')->constrained('pedidos')->cascadeOnDelete();
            $table->decimal('monto', 12, 2)->default(0);
            $table->string('metodo_pago')->nullable();
            $table->string('referencia')->nullable();
            $table->string('tipo')->nullable();
            $table->unsignedBigInteger('usuario_id')->nullable();
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('caja_sesiones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('caja_id')->constrained('cajas')->cascadeOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->decimal('monto_apertura', 12, 2)->default(0);
            $table->decimal('monto_cierre', 12, 2)->nullable();
            $table->decimal('monto_esperado', 12, 2)->nullable();
            $table->decimal('diferencia', 12, 2)->nullable();
            $table->string('estado')->default('abierta');
            $table->timestamp('apertura_at')->nullable();
            $table->timestamp('cierre_at')->nullable();
            $table->text('notas_cierre')->nullable();
            $table->timestamps();
        });

        Schema::create('caja_retiros', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sesion_id')->constrained('caja_sesiones')->cascadeOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->decimal('monto', 12, 2);
            $table->string('motivo')->nullable();
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('caja_movimientos', function (Blueprint $table) {
            $table->id();
            $table->string('tipo');
            $table->decimal('monto', 12, 2)->default(0);
            $table->string('concepto')->nullable();
            $table->string('referencia_tipo')->nullable();
            $table->unsignedBigInteger('referencia_id')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('inventario_movimientos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->foreignId('ubicacion_id')->nullable()->constrained('ubicaciones')->nullOnDelete();
            $table->foreignId('ubicacion_destino_id')->nullable()->constrained('ubicaciones')->nullOnDelete();
            $table->string('tipo');
            $table->integer('cantidad');
            $table->integer('stock_anterior');
            $table->integer('stock_nuevo');
            $table->string('referencia_tipo')->nullable();
            $table->unsignedBigInteger('referencia_id')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('stock_ubicacion', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->foreignId('ubicacion_id')->constrained('ubicaciones')->cascadeOnDelete();
            $table->integer('stock')->default(0);
            $table->unique(['producto_id', 'ubicacion_id']);
        });

        Schema::create('inventario_ubicacion', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->foreignId('ubicacion_id')->constrained('ubicaciones')->cascadeOnDelete();
            $table->integer('cantidad')->default(0);
            $table->integer('cantidad_reservada')->default(0);
            $table->integer('stock_minimo')->nullable();
            $table->integer('stock_maximo')->nullable();
            $table->string('estado')->default('activo');
            $table->timestamps();
            $table->unique(['producto_id', 'ubicacion_id']);
        });

        Schema::create('ajustes_inventario', function (Blueprint $table) {
            $table->id();
            $table->string('numero_ajuste')->unique();
            $table->string('tipo');
            $table->string('motivo');
            $table->text('motivo_detalle')->nullable();
            $table->foreignId('ubicacion_id')->nullable()->constrained('ubicaciones')->nullOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->string('estado')->default('borrador');
            $table->text('notas')->nullable();
            $table->timestamp('aplicado_at')->nullable();
            $table->timestamps();
        });

        Schema::create('ajuste_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ajuste_id')->constrained('ajustes_inventario')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('stock_sistema')->default(0);
            $table->integer('stock_fisico')->nullable();
            $table->integer('cantidad_ajuste')->default(0);
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('combo_productos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('combo_id')->constrained('combos')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->integer('cantidad')->default(1);
            $table->timestamps();
        });

        Schema::create('cupon_usos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cupon_id')->constrained('cupones')->cascadeOnDelete();
            $table->foreignId('venta_id')->constrained('ventas')->cascadeOnDelete();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->decimal('descuento_aplicado', 12, 2);
            $table->timestamps();
        });

        Schema::create('cuentas_cobrar', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->constrained('clientes')->cascadeOnDelete();
            $table->foreignId('venta_id')->nullable()->constrained('ventas')->nullOnDelete();
            $table->decimal('monto_total', 12, 2);
            $table->decimal('monto_pagado', 12, 2)->default(0);
            $table->decimal('saldo_pendiente', 12, 2);
            $table->date('fecha_vencimiento')->nullable();
            $table->string('estado')->default('pendiente');
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('cuentas_cobrar_pagos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cuenta_id')->constrained('cuentas_cobrar')->cascadeOnDelete();
            $table->decimal('monto', 12, 2);
            $table->string('metodo_pago');
            $table->string('referencia')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('cuentas_pagar', function (Blueprint $table) {
            $table->id();
            $table->foreignId('proveedor_id')->constrained('proveedores')->cascadeOnDelete();
            $table->foreignId('compra_id')->nullable()->constrained('compras')->nullOnDelete();
            $table->decimal('monto_total', 12, 2);
            $table->decimal('monto_pagado', 12, 2)->default(0);
            $table->decimal('saldo_pendiente', 12, 2);
            $table->date('fecha_vencimiento')->nullable();
            $table->string('estado')->default('pendiente');
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('cuentas_pagar_pagos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cuenta_id')->constrained('cuentas_pagar')->cascadeOnDelete();
            $table->decimal('monto', 12, 2);
            $table->string('metodo_pago');
            $table->string('referencia')->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('lista_precios_clientes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('lista_id');
            $table->unsignedBigInteger('cliente_id');
            $table->timestamp('created_at')->nullable();
            $table->unique(['lista_id', 'cliente_id']);
        });

        Schema::create('lista_precios_productos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('lista_id');
            $table->unsignedBigInteger('producto_id');
            $table->decimal('precio_especial', 12, 2);
            $table->timestamp('created_at')->nullable();
            $table->unique(['lista_id', 'producto_id']);
        });

        Schema::create('lista_precio_productos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lista_id')->constrained('listas_precios')->cascadeOnDelete();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->decimal('precio', 12, 2);
            $table->unique(['lista_id', 'producto_id']);
        });

        Schema::create('asiento_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('asiento_id')->constrained('asientos_contables')->cascadeOnDelete();
            $table->foreignId('cuenta_id')->constrained('cuentas_contables')->cascadeOnDelete();
            $table->decimal('debe', 12, 2)->default(0);
            $table->decimal('haber', 12, 2)->default(0);
            $table->text('descripcion')->nullable();
            $table->timestamps();
        });

        Schema::create('planilla_pagos', function (Blueprint $table) {
            $table->id();
            $table->date('periodo');
            $table->date('fecha_pago');
            $table->foreignId('empleado_id')->constrained('empleados')->cascadeOnDelete();
            $table->decimal('salario_base', 12, 2);
            $table->decimal('horas_extra_cantidad', 10, 2)->default(0);
            $table->decimal('horas_extra', 12, 2)->default(0);
            $table->decimal('monto_horas_extra', 12, 2)->default(0);
            $table->decimal('comisiones', 12, 2)->default(0);
            $table->decimal('deducciones', 12, 2)->default(0);
            $table->decimal('total_pagar', 12, 2);
            $table->text('detalle_deducciones')->nullable();
            $table->string('estado')->default('pendiente');
            $table->timestamps();
        });

        Schema::create('formulario_respuestas', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('formulario_id');
            $table->json('datos')->nullable();
            $table->json('datos_json')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent', 255)->nullable();
            $table->boolean('atendido')->default(false);
            $table->timestamp('atendido_en')->nullable();
            $table->timestamps();
            $table->index('formulario_id');
        });

        Schema::create('email_destinatarios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campana_id')->constrained('campanas_email')->cascadeOnDelete();
            $table->string('email');
            $table->string('nombre')->nullable();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->string('estado')->default('pendiente');
            $table->timestamp('enviado_at')->nullable();
            $table->timestamp('abierto_at')->nullable();
            $table->string('error_mensaje')->nullable();
            $table->timestamps();
            $table->index('campana_id');
        });

        Schema::create('email_recipients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained('email_campaigns')->cascadeOnDelete();
            $table->string('email');
            $table->string('nombre')->nullable();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->string('estado')->default('pendiente');
            $table->timestamp('enviado_at')->nullable();
            $table->timestamp('abierto_at')->nullable();
            $table->timestamp('click_at')->nullable();
            $table->string('device')->nullable();
            $table->string('error_mensaje')->nullable();
            $table->timestamps();
            $table->index('campaign_id');
            $table->index('estado');
        });

        Schema::create('email_analytics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained('email_campaigns')->cascadeOnDelete();
            $table->date('fecha');
            $table->integer('aperturas')->default(0);
            $table->integer('clics')->default(0);
            $table->integer('rebotes')->default(0);
            $table->integer('enviados')->default(0);
            $table->timestamps();
            $table->unique(['campaign_id', 'fecha']);
        });

        Schema::create('rentabilidad_productos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('producto_id')->constrained('productos')->cascadeOnDelete();
            $table->string('periodo', 7);
            $table->integer('unidades_vendidas')->default(0);
            $table->decimal('ingresos', 14, 2)->default(0);
            $table->decimal('costo_total', 14, 2)->default(0);
            $table->decimal('ganancia', 14, 2)->default(0);
            $table->decimal('margen_porcentaje', 5, 2)->default(0);
            $table->integer('devoluciones')->default(0);
            $table->timestamps();
            $table->unique(['producto_id', 'periodo']);
        });

        Schema::create('facturacion_electronica', function (Blueprint $table) {
            $table->id();
            $table->foreignId('venta_id')->nullable()->constrained('ventas')->nullOnDelete();
            $table->string('clave_numerica', 50)->nullable();
            $table->string('numero_consecutivo', 20)->nullable();
            $table->string('tipo_documento', 10)->default('FE');
            $table->string('estado_hacienda', 20)->default('pendiente');
            $table->text('xml_enviado')->nullable();
            $table->text('xml_respuesta')->nullable();
            $table->string('mensaje_hacienda')->nullable();
            $table->timestamp('fecha_emision')->nullable();
            $table->timestamp('fecha_respuesta')->nullable();
            $table->string('email_enviado_a')->nullable();
            $table->timestamps();
            $table->index('clave_numerica');
            $table->index('venta_id');
        });

        Schema::create('crm_oportunidades', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->foreignId('etapa_id')->nullable()->constrained('crm_etapas')->nullOnDelete();
            $table->decimal('valor_estimado', 14, 2)->default(0);
            $table->integer('probabilidad')->default(50);
            $table->date('fecha_cierre_estimada')->nullable();
            $table->string('estado')->default('abierta');
            $table->text('notas')->nullable();
            $table->string('origen')->nullable();
            $table->timestamps();
            $table->index('estado');
        });

        Schema::create('crm_actividades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('oportunidad_id')->nullable()->constrained('crm_oportunidades')->cascadeOnDelete();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->nullOnDelete();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->string('tipo', 50);
            $table->string('titulo');
            $table->text('descripcion')->nullable();
            $table->timestamp('fecha_programada')->nullable();
            $table->timestamp('fecha_completada')->nullable();
            $table->string('estado')->default('pendiente');
            $table->timestamps();
        });

        Schema::create('presupuesto_detalle', function (Blueprint $table) {
            $table->id();
            $table->foreignId('presupuesto_id')->constrained('presupuestos')->cascadeOnDelete();
            $table->string('categoria');
            $table->decimal('monto_asignado', 14, 2)->default(0);
            $table->decimal('monto_ejecutado', 14, 2)->default(0);
            $table->text('notas')->nullable();
            $table->timestamps();
        });

        Schema::create('tesoreria_movimientos', function (Blueprint $table) {
            $table->id();
            $table->string('tipo', 20);
            $table->string('categoria', 100)->nullable();
            $table->decimal('monto', 14, 2);
            $table->string('descripcion')->nullable();
            $table->string('referencia')->nullable();
            $table->string('metodo_pago', 50)->nullable();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->unsignedBigInteger('ubicacion_id')->nullable();
            $table->date('fecha');
            $table->string('estado')->default('confirmado');
            $table->text('notas')->nullable();
            $table->timestamps();
            $table->index(['tipo', 'fecha']);
        });

        Schema::create('auditoria', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->nullable()->constrained('usuarios')->nullOnDelete();
            $table->string('accion', 10);
            $table->string('modulo', 100);
            $table->text('descripcion')->nullable();
            $table->unsignedBigInteger('auditable_id')->nullable();
            $table->string('auditable_type', 100)->nullable();
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent', 500)->nullable();
            $table->string('url', 500)->nullable();
            $table->integer('codigo_respuesta')->nullable();
            $table->timestamps();
            $table->index(['usuario_id', 'created_at']);
            $table->index('modulo');
            $table->index(['auditable_type', 'auditable_id']);
        });

        Schema::create('productividad_sesiones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->timestamp('inicio_sesion');
            $table->timestamp('fin_sesion')->nullable();
            $table->integer('duracion_minutos')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent', 500)->nullable();
            $table->decimal('ventas_generadas', 12, 2)->default(0);
            $table->integer('cantidad_ventas')->default(0);
            $table->timestamps();
            $table->index('usuario_id');
        });

        Schema::create('sesiones_log', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->string('accion');
            $table->string('ip')->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();
        });

        Schema::create('chat_participantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_id')->constrained('chats')->cascadeOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamp('last_read_at')->nullable();
            $table->unique(['chat_id', 'usuario_id']);
        });

        Schema::create('chat_mensajes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_id')->constrained('chats')->cascadeOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->text('contenido');
            $table->string('archivo_url')->nullable();
            $table->string('archivo_nombre')->nullable();
            $table->string('archivo_tipo')->nullable();
            $table->unsignedBigInteger('archivo_size')->nullable();
            $table->timestamps();
        });

        Schema::create('notificacion_usuarios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('notificacion_id')->constrained('notificaciones')->cascadeOnDelete();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->timestamp('leido_at')->nullable();
            $table->timestamp('descartado_at')->nullable();
            $table->timestamps();
            $table->unique(['notificacion_id', 'usuario_id']);
        });
    }

    public function down(): void
    {
        // Orden inverso para respetar foreign keys
        Schema::dropIfExists('notificacion_usuarios');
        Schema::dropIfExists('chat_mensajes');
        Schema::dropIfExists('chat_participantes');
        Schema::dropIfExists('sesiones_log');
        Schema::dropIfExists('productividad_sesiones');
        Schema::dropIfExists('auditoria');
        Schema::dropIfExists('tesoreria_movimientos');
        Schema::dropIfExists('presupuesto_detalle');
        Schema::dropIfExists('crm_actividades');
        Schema::dropIfExists('crm_oportunidades');
        Schema::dropIfExists('facturacion_electronica');
        Schema::dropIfExists('rentabilidad_productos');
        Schema::dropIfExists('email_analytics');
        Schema::dropIfExists('email_recipients');
        Schema::dropIfExists('email_destinatarios');
        Schema::dropIfExists('formulario_respuestas');
        Schema::dropIfExists('planilla_pagos');
        Schema::dropIfExists('asiento_detalle');
        Schema::dropIfExists('lista_precio_productos');
        Schema::dropIfExists('lista_precios_productos');
        Schema::dropIfExists('lista_precios_clientes');
        Schema::dropIfExists('cuentas_pagar_pagos');
        Schema::dropIfExists('cuentas_pagar');
        Schema::dropIfExists('cuentas_cobrar_pagos');
        Schema::dropIfExists('cuentas_cobrar');
        Schema::dropIfExists('cupon_usos');
        Schema::dropIfExists('combo_productos');
        Schema::dropIfExists('ajuste_detalle');
        Schema::dropIfExists('ajustes_inventario');
        Schema::dropIfExists('inventario_ubicacion');
        Schema::dropIfExists('stock_ubicacion');
        Schema::dropIfExists('inventario_movimientos');
        Schema::dropIfExists('caja_movimientos');
        Schema::dropIfExists('caja_retiros');
        Schema::dropIfExists('caja_sesiones');
        Schema::dropIfExists('pedido_pagos');
        Schema::dropIfExists('pedido_detalle');
        Schema::dropIfExists('pedidos');
        Schema::dropIfExists('cotizacion_detalle');
        Schema::dropIfExists('cotizaciones');
        Schema::dropIfExists('traspaso_detalle');
        Schema::dropIfExists('traspasos');
        Schema::dropIfExists('compra_detalle');
        Schema::dropIfExists('compras');
        Schema::dropIfExists('nota_credito_usos');
        Schema::dropIfExists('nota_credito_detalle');
        Schema::dropIfExists('notas_credito');
        Schema::dropIfExists('devolucion_detalle');
        Schema::dropIfExists('devoluciones');
        Schema::dropIfExists('venta_ubicacion');
        Schema::dropIfExists('venta_detalle');
        Schema::dropIfExists('ventas');
        Schema::dropIfExists('proveedor_productos');
        Schema::dropIfExists('cliente_etiquetas');
        Schema::dropIfExists('cliente_notas');
        Schema::dropIfExists('producto_imagenes');
        Schema::dropIfExists('producto_variantes');
        Schema::dropIfExists('rol_permisos');
        Schema::dropIfExists('empleados');
        Schema::dropIfExists('asientos_contables');
        Schema::dropIfExists('presupuestos');
        Schema::dropIfExists('chats');
        Schema::dropIfExists('notificaciones');
        Schema::dropIfExists('email_templates');
        Schema::dropIfExists('plantillas_email');
        Schema::dropIfExists('email_campaigns');
        Schema::dropIfExists('campanas_email');
        Schema::dropIfExists('cajas');
        Schema::dropIfExists('cupones');
        Schema::dropIfExists('promociones');
        Schema::dropIfExists('combos');
        Schema::dropIfExists('productos');
        Schema::dropIfExists('proveedores');
        Schema::dropIfExists('clientes');
        Schema::dropIfExists('usuarios');
        Schema::dropIfExists('formularios');
        Schema::dropIfExists('cotizacion_configuracion');
        Schema::dropIfExists('ticket_configuracion');
        Schema::dropIfExists('crm_etapas');
        Schema::dropIfExists('cuentas_contables');
        Schema::dropIfExists('listas_precios');
        Schema::dropIfExists('cliente_categorias');
        Schema::dropIfExists('configuracion');
        Schema::dropIfExists('ubicaciones');
        Schema::dropIfExists('etiquetas');
        Schema::dropIfExists('categorias');
        Schema::dropIfExists('permisos');
        Schema::dropIfExists('roles');
        Schema::dropIfExists('personal_access_tokens');
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('failed_jobs');
        Schema::dropIfExists('job_batches');
        Schema::dropIfExists('jobs');
        Schema::dropIfExists('cache_locks');
        Schema::dropIfExists('cache');
    }
};
