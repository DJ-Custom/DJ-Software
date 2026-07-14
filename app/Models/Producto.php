<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Producto extends Model
{
    use Auditable;
    protected $table = 'productos';

    protected $fillable = [
        'codigo', 'codigo_barras', 'nombre', 'descripcion', 'categoria_id', 'proveedor_id',
        'precio_compra', 'precio_venta', 'stock', 'stock_minimo', 'stock_maximo',
        'unidad', 'imagen', 'impuesto', 'margen_ganancia', 'peso',
        'costo_envio', 'costo_marketing', 'costo_logistica',
        'visible_web', 'activo',
    ];

    protected function casts(): array
    {
        return [
            'precio_compra' => 'decimal:2',
            'precio_venta' => 'decimal:2',
            'impuesto' => 'decimal:2',
            'activo' => 'boolean',
            'visible_web' => 'boolean',
        ];
    }

    public function categoria()
    {
        return $this->belongsTo(Categoria::class, 'categoria_id');
    }

    public function proveedor()
    {
        return $this->belongsTo(Proveedor::class, 'proveedor_id');
    }

    public function variantes()
    {
        return $this->hasMany(ProductoVariante::class, 'producto_id');
    }

    public function imagenes()
    {
        return $this->hasMany(ProductoImagen::class, 'producto_id');
    }

    public function inventarioUbicaciones()
    {
        return $this->hasMany(InventarioUbicacion::class, 'producto_id');
    }

    public function movimientos()
    {
        return $this->hasMany(InventarioMovimiento::class, 'producto_id')->orderByDesc('created_at');
    }

    public function stockUbicacion($ubicacionId)
    {
        $inv = $this->inventarioUbicaciones()->where('ubicacion_id', $ubicacionId)->first();
        return $inv ? $inv->cantidad : 0;
    }

    public function scopeActivo($query)
    {
        return $query->where('activo', 1);
    }

    public function scopeBajoStock($query)
    {
        return $query->whereColumn('stock', '<=', 'stock_minimo')->where('activo', 1);
    }

    public function scopeBajoStockUbicacion($query, $ubicacionId = null)
    {
        return $query->whereHas('inventarioUbicaciones', function ($q) use ($ubicacionId) {
            if ($ubicacionId) {
                $q->where('ubicacion_id', $ubicacionId);
            }
            $q->whereRaw('cantidad <= COALESCE(stock_minimo, 0)');
        })->where('activo', 1);
    }
}
