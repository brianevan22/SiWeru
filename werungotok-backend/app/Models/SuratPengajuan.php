<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SuratPengajuan extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'jenis_surat',
        'keperluan',
        'dokumen_pendukung',
        'status',
        'file_hasil',
        'catatan_admin',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /// Berkas persyaratan yang diunggah terpisah per syarat.
    public function berkas()
    {
        return $this->hasMany(SuratBerkas::class, 'surat_pengajuan_id');
    }
}