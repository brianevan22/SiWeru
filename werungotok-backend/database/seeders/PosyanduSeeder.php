<?php

namespace Database\Seeders;

use App\Models\PosyanduInfo;
use App\Models\PosyanduJadwal;
use App\Models\SiteSetting;
use Illuminate\Database\Seeder;

class PosyanduSeeder extends Seeder
{
    public function run(): void
    {
        $jadwal = [
            ['nama_posyandu' => 'ILP BULAKMOJO', 'kategori' => 'ilp', 'jan' => 5, 'feb' => 2, 'mar' => 2, 'apr' => 1, 'mei' => 2, 'jun' => 2, 'jul' => 1, 'agu' => 1, 'sep' => 1, 'okt' => 1, 'nop' => 2, 'des' => 1],
            ['nama_posyandu' => 'ILP WERU', 'kategori' => 'ilp', 'jan' => 6, 'feb' => 3, 'mar' => 3, 'apr' => 2, 'mei' => 4, 'jun' => 3, 'jul' => 2, 'agu' => 3, 'sep' => 2, 'okt' => 5, 'nop' => 3, 'des' => 2],
            ['nama_posyandu' => 'ILP BABADAN', 'kategori' => 'ilp', 'jan' => 7, 'feb' => 4, 'mar' => 4, 'apr' => 7, 'mei' => 5, 'jun' => 4, 'jul' => 4, 'agu' => 4, 'sep' => 3, 'okt' => 3, 'nop' => 4, 'des' => 3],
            ['nama_posyandu' => 'ILP NGOTOK', 'kategori' => 'ilp', 'jan' => 8, 'feb' => 5, 'mar' => 5, 'apr' => 8, 'mei' => 6, 'jun' => 8, 'jul' => 6, 'agu' => 5, 'sep' => 8, 'okt' => 6, 'nop' => 5, 'des' => 8],
            ['nama_posyandu' => 'ILP NGATES', 'kategori' => 'ilp', 'jan' => 12, 'feb' => 9, 'mar' => 9, 'apr' => 9, 'mei' => 7, 'jun' => 9, 'jul' => 7, 'agu' => 6, 'sep' => 7, 'okt' => 7, 'nop' => 9, 'des' => 7],
            ['nama_posyandu' => 'ILP PERUMNAS', 'kategori' => 'ilp', 'jan' => 10, 'feb' => 7, 'mar' => 7, 'apr' => 11, 'mei' => 9, 'jun' => 6, 'jul' => 11, 'agu' => 8, 'sep' => 5, 'okt' => 10, 'nop' => 7, 'des' => 5],
            ['nama_posyandu' => 'LANSIA PERUMNAS', 'kategori' => 'lansia', 'jan' => 14, 'feb' => 11, 'mar' => 11, 'apr' => 15, 'mei' => 13, 'jun' => 10, 'jul' => 15, 'agu' => 12, 'sep' => 9, 'okt' => 14, 'nop' => 11, 'des' => 16],
            ['nama_posyandu' => 'PERTEMUAN KADER', 'kategori' => 'kader', 'jan' => 20, 'feb' => 24, 'mar' => 17, 'apr' => 21, 'mei' => 19, 'jun' => 17, 'jul' => 21, 'agu' => 18, 'sep' => 22, 'okt' => 21, 'nop' => 17, 'des' => 22],
            ['nama_posyandu' => 'IMUNISASI BALITA', 'kategori' => 'imunisasi', 'jan' => 21, 'feb' => 21, 'mar' => 26, 'apr' => 20, 'mei' => 20, 'jun' => 20, 'jul' => 20, 'agu' => 20, 'sep' => 21, 'okt' => 20, 'nop' => 21, 'des' => 21],
        ];

        foreach ($jadwal as $i => $row) {
            PosyanduJadwal::updateOrCreate(
                ['nama_posyandu' => $row['nama_posyandu']],
                $row + ['urutan' => $i]
            );
        }

        $keterangan = [
            ['judul' => 'Posyandu ILP', 'isi' => 'Layanan Integrasi Layanan Primer (ILP) mencakup wilayah Bulakmojo, Weru, Babadan, Ngotok, Ngates, dan Perumnas yang dilaksanakan secara rutin tiap bulan.'],
            ['judul' => 'Posyandu Lansia', 'isi' => 'Khusus melayani pemeriksaan kesehatan lansia secara berkala (terutama di wilayah Perumnas).'],
            ['judul' => 'Pertemuan Kader & Imunisasi Balita', 'isi' => 'Agenda bulanan untuk evaluasi kader PKK serta pemberian imunisasi lengkap bagi balita.'],
        ];

        foreach ($keterangan as $i => $row) {
            PosyanduInfo::updateOrCreate(
                ['judul' => $row['judul']],
                $row + ['urutan' => $i]
            );
        }

        SiteSetting::set('posyandu_ketua_pkk', 'Beattealeas');
        SiteSetting::set('posyandu_koordinator_kader', 'Endang Dwi Purwanti');
    }
}
