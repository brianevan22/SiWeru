<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PosyanduJadwal extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama_posyandu', 'kategori',
        'jan', 'feb', 'mar', 'apr', 'mei', 'jun',
        'jul', 'agu', 'sep', 'okt', 'nop', 'des',
        'urutan',
    ];
}
