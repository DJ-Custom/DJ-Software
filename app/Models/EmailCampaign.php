<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class EmailCampaign extends Model
{
    use Auditable;
    protected $table = 'email_campaigns';

    protected $fillable = [
        'nombre', 'asunto', 'html_content', 'json_content', 'thumbnail',
        'estado', 'usuario_id', 'programada_para', 'enviada_en',
        'total_recipients', 'total_enviados', 'total_abiertos', 'total_clicks', 'total_rebotes'
    ];

    protected $casts = [
        'programada_para' => 'datetime',
        'enviada_en' => 'datetime',
    ];

    public function creador()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function recipients()
    {
        return $this->hasMany(EmailRecipient::class, 'campaign_id');
    }

    public function analytics()
    {
        return $this->hasMany(EmailAnalytics::class, 'campaign_id');
    }
}
