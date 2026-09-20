<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InfoSuratSetting extends Model
{
    protected $table = 'info_surat_settings';

    protected $fillable = [
        'gambar_alur',
        'gambar_syarat',
        'gambar_posyandu',
        'keterangan',
    ];
}