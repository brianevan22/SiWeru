<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SuratBerkas extends Model
{
    protected $table = 'surat_berkas';

    protected $fillable = [
        'surat_pengajuan_id',
        'syarat_key',
        'file_path',
    ];

    public function surat(): BelongsTo
    {
        return $this->belongsTo(SuratPengajuan::class, 'surat_pengajuan_id');
    }
}