<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AlurPelayanan;
use App\Models\InfoSuratSetting;
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

    /**
     * Gambar & keterangan halaman Info Surat yang bisa diatur admin.
     * Publik: dibaca oleh halaman Info Surat di aplikasi.
     */
    public function settings()
    {
        $s = InfoSuratSetting::first();

        return response()->json(['data' => [
            'keterangan' => $s?->keterangan,
            'gambar_alur' => $s?->gambar_alur,
            'gambar_syarat' => $s?->gambar_syarat,
            'gambar_posyandu' => $s?->gambar_posyandu,
        ]]);
    }
}