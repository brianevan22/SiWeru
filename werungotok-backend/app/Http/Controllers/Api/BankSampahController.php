<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JenisSampah;
use App\Models\KetentuanSampah;
use App\Models\SiteSetting;

class BankSampahController extends Controller
{
    public function index()
    {
        return response()->json([
            'judul' => 'Program Bank Sampah',
            'deskripsi' => SiteSetting::get(
                'bank_sampah_deskripsi',
                'Mari ubah sampah menjadi berkah. Tukarkan sampah anorganik Anda yang sudah dipilah di rumah dengan tabungan di Kelurahan Werungotok.'
            ),
            'jadwal_penukaran' => SiteSetting::get('bank_sampah_jadwal', 'Setiap Minggu ke-2'),
            'ketentuan' => KetentuanSampah::orderBy('urutan')->get(),
            'jenis_sampah' => JenisSampah::orderBy('urutan')->get(),
        ]);
    }
}
