<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AlurPelayanan;
use App\Models\SyaratSurat;

class InfoSuratController extends Controller
{
    public function alur()
    {
        return response()->json([
            'judul' => 'Alur Pelayanan Digital',
            'langkah' => AlurPelayanan::orderBy('urutan')->get(),
        ]);
    }

    public function syarat()
    {
        return response()->json([
            'judul' => 'Persyaratan Dokumen Utama',
            'syarat' => SyaratSurat::orderBy('urutan')->get(),
        ]);
    }
}
