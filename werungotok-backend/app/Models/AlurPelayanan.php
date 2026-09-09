<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AlurPelayanan extends Model
{
    use HasFactory;

    protected $fillable = ['judul_langkah', 'deskripsi', 'urutan'];
}
