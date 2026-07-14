<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class EmailAnalytics extends Model
{
    use Auditable;
    protected $table = 'email_analytics';

    protected $fillable = [
        'campaign_id', 'fecha', 'aperturas', 'clics', 'rebotes', 'enviados'
    ];

    public $timestamps = false;

    public function campaign()
    {
        return $this->belongsTo(EmailCampaign::class, 'campaign_id');
    }
}
