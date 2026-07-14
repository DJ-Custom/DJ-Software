<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class EmailRecipient extends Model
{
    use Auditable;
    protected $table = 'email_recipients';

    protected $fillable = [
        'campaign_id', 'email', 'nombre', 'cliente_id', 'estado',
        'enviado_at', 'abierto_at', 'click_at', 'device', 'error_mensaje'
    ];

    protected $casts = [
        'enviado_at' => 'datetime',
        'abierto_at' => 'datetime',
        'click_at' => 'datetime',
    ];

    public function campaign()
    {
        return $this->belongsTo(EmailCampaign::class, 'campaign_id');
    }
}
