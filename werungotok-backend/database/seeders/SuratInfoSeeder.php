<?php

namespace Database\Seeders;

use App\Models\AlurPelayanan;
use App\Models\SyaratSurat;
use Illuminate\Database\Seeder;

class SuratInfoSeeder extends Seeder
{
    public function run(): void
    {
        $alur = [
            ['judul_langkah' => 'Masyarakat', 'deskripsi' => 'Membawa Surat Pengantar RT/RW, FC KK, FC KTP, dan dokumen pendukung sesuai surat keterangan yang dibutuhkan.'],
            ['judul_langkah' => 'Kelurahan Memeriksa', 'deskripsi' => 'Memeriksa kelengkapan berkas. Jika lengkap, diproses 5-10 menit. Jika belum lengkap, dikembalikan untuk dilengkapi.'],
            ['judul_langkah' => 'Proses Kelurahan', 'deskripsi' => 'Proses pengerjaan 10-15 menit (jika ada revisi 5-7 menit).'],
            ['judul_langkah' => 'Verifikasi & Pengesahan', 'deskripsi' => 'Proses verifikasi Kasi dan Sekretaris Kelurahan. Kemudian register surat dan proses tanda tangan Lurah.'],
            ['judul_langkah' => 'Selesai', 'deskripsi' => 'Kelurahan memberikan Surat Pelayanan melalui WhatsApp pemohon yang aktif berupa file PDF ke warga.'],
        ];
        foreach ($alur as $i => $row) {
            AlurPelayanan::updateOrCreate(['judul_langkah' => $row['judul_langkah']], $row + ['urutan' => $i]);
        }

        $syarat = [
            [
                'nama_surat' => 'Surat Kematian',
                'daftar_syarat' => [
                    'Pengantar RT/RW (WAJIB)',
                    'FC KK/KTP yang meninggal (WAJIB)',
                    'Surat Kematian RS (PENDUKUNG)',
                    'Materai 10.000 jika lewat 3 bln',
                ],
            ],
            [
                'nama_surat' => 'SKCK',
                'daftar_syarat' => [
                    'Pengantar RT/RW (WAJIB)',
                    'FC KK & KTP (WAJIB)',
                ],
            ],
            [
                'nama_surat' => 'SKTM',
                'daftar_syarat' => [
                    'Pengantar RT/RW (WAJIB)',
                    'FC KK/KTP (WAJIB)',
                    'Surat RS untuk Pasien Darurat',
                ],
            ],
            [
                'nama_surat' => 'Keterangan Usaha',
                'daftar_syarat' => [
                    'Pengantar RT/RW (WAJIB)',
                    'FC KK/KTP (WAJIB)',
                    'Surat Pernyataan Bermaterai (WAJIB)',
                    'Foto Usaha (PENDUKUNG)',
                ],
            ],
        ];
        foreach ($syarat as $i => $row) {
            SyaratSurat::updateOrCreate(['nama_surat' => $row['nama_surat']], $row + ['urutan' => $i]);
        }
    }
}
