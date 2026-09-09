<?php

namespace Database\Seeders;

use App\Models\JenisSampah;
use App\Models\KetentuanSampah;
use App\Models\SiteSetting;
use Illuminate\Database\Seeder;

class BankSampahSeeder extends Seeder
{
    public function run(): void
    {
        SiteSetting::set(
            'bank_sampah_deskripsi',
            'Mari ubah sampah menjadi berkah. Tukarkan sampah anorganik Anda yang sudah dipilah di rumah dengan tabungan di Kelurahan Werungotok.'
        );
        SiteSetting::set('bank_sampah_jadwal', 'Setiap Minggu ke-2');

        $ketentuan = [
            'Sampah harus dalam keadaan bersih (wajib dibilas air jika bekas botol minuman / kaleng makanan).',
            'Sampah sudah dipilah sesuai jenisnya (plastik keras, plastik kemasan, kertas, dan besi/logam).',
            'Wajib membawa buku tabungan Bank Sampah saat jadwal penimbangan rutin (Setiap Minggu ke-2).',
        ];
        foreach ($ketentuan as $i => $isi) {
            KetentuanSampah::updateOrCreate(['isi' => $isi], ['isi' => $isi, 'urutan' => $i]);
        }

        $jenis = [
            ['nama' => 'Botol Plastik', 'icon' => 'bottle-water'],
            ['nama' => 'Kardus & Kertas', 'icon' => 'box'],
            ['nama' => 'Kaleng / Besi', 'icon' => 'can-food'],
            ['nama' => 'Botol Kaca', 'icon' => 'glass-water'],
            ['nama' => 'Kabel Bekas', 'icon' => 'plug'],
            ['nama' => 'Minyak Jelantah', 'icon' => 'oil-can'],
        ];
        foreach ($jenis as $i => $row) {
            JenisSampah::updateOrCreate(['nama' => $row['nama']], $row + ['urutan' => $i]);
        }
    }
}
