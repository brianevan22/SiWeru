<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JenisSurat extends Model
{
    use HasFactory;

    protected $table = 'jenis_surats';

    protected $fillable = [
        'kode',
        'nama_surat',
        'keterangan',
        'syarat_required',
        'is_active',
    ];

    protected $casts = [
        'syarat_required' => 'array',
        'is_active' => 'boolean',
    ];
}