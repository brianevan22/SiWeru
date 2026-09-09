<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SyaratSurat extends Model
{
    use HasFactory;

    protected $fillable = ['nama_surat', 'daftar_syarat', 'urutan'];

    protected function casts(): array
    {
        return [
            'daftar_syarat' => 'array',
        ];
    }
}
