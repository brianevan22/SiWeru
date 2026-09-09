<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PosyanduInfo;
use App\Models\PosyanduJadwal;
use App\Models\SiteSetting;

class PosyanduController extends Controller
{
    public function index()
    {
        return response()->json([
            'judul' => 'Jadwal Posyandu Werungotok 2026',
            'jadwal' => PosyanduJadwal::orderBy('urutan')->get(),
            'keterangan' => PosyanduInfo::orderBy('urutan')->get(),
            'ketua_pkk' => SiteSetting::get('posyandu_ketua_pkk'),
            'koordinator_kader' => SiteSetting::get('posyandu_koordinator_kader'),
        ]);
    }
}
