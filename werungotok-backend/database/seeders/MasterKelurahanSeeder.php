<?php

namespace Database\Seeders;

use App\Models\JenisSurat;
use App\Models\SiteSetting;
use Illuminate\Database\Seeder;

class MasterKelurahanSeeder extends Seeder
{
    public function run(): void
    {
        $dataSurat = [
            [
                'kode' => 'SK_BELUM_MENIKAH',
                'nama_surat' => 'Surat Keterangan Belum Menikah',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_BELUM_BEKERJA',
                'nama_surat' => 'Surat Keterangan Belum Bekerja',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_BELUM_PUNYA_RUMAH',
                'nama_surat' => 'Surat Keterangan Belum Mempunyai Rumah',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_MASIH_SEKOLAH',
                'nama_surat' => 'Surat Keterangan Masih Sekolah',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_JANDA_DUDA',
                'nama_surat' => 'Surat Keterangan Janda/Duda',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_GANTI_PEKERJAAN_KK',
                'nama_surat' => 'Surat Keterangan Ganti Pekerjaan di KK',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'form_f106_materai']
            ],
            [
                'kode' => 'SK_IJIN_KERAMAIAN',
                'nama_surat' => 'Surat Keterangan Ijin Keramaian',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_advis_okm']
            ],
            [
                'kode' => 'SK_KEHILANGAN',
                'nama_surat' => 'Surat Keterangan Kehilangan',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan']
            ],
            [
                'kode' => 'SK_PASANGAN_LUAR_NEGERI',
                'nama_surat' => 'Surat Keterangan Suami/Istri Bekerja di Luar Negeri/Kota',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_WALI',
                'nama_surat' => 'Surat Keterangan Wali',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk_mempelai', 'fc_ktp_mempelai', 'fc_kk_wali', 'fc_ktp_wali']
            ],
            [
                'kode' => 'SK_BEPERGIAN',
                'nama_surat' => 'Surat Keterangan Bepergian',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_REKOM_BBM',
                'nama_surat' => 'Surat Keterangan Rekom Pembelian BBM',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_BEDA_NAMA',
                'nama_surat' => 'Surat Keterangan Beda Nama (1 Orang Sama)',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'dokumen_pembanding']
            ],
            [
                'kode' => 'SK_CUTI_PABRIK',
                'nama_surat' => 'Surat Keterangan Ijin Cuti Bekerja di Pabrik',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp']
            ],
            [
                'kode' => 'SK_SPPT',
                'nama_surat' => 'Surat Keterangan SPPT',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'fc_sppt_pbb']
            ],
            [
                'kode' => 'SK_KEMATIAN',
                'nama_surat' => 'Surat Keterangan Kematian (> 3 Bulan)',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk_almarhum', 'fc_ktp_almarhum', 'fc_kk_pelapor', 'fc_ktp_pelapor', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_KELAHIRAN',
                'nama_surat' => 'Surat Keterangan Kelahiran (> 3 Bulan)',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_TIDAK_DINAFKAHI',
                'nama_surat' => 'Surat Keterangan Tidak Dinafkahi',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_NUMPANG_RUMAH',
                'nama_surat' => 'Surat Keterangan Numpang Rumah',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan_materai']
            ],
            [
                'kode' => 'SK_TIDAK_BEKERJA',
                'nama_surat' => 'Surat Keterangan Tidak Bekerja',
                'syarat_required' => ['pengantar_rt', 'pengantar_rw', 'fc_kk', 'fc_ktp', 'surat_pernyataan']
            ],
        ];

        foreach ($dataSurat as $surat) {
            JenisSurat::updateOrCreate(['kode' => $surat['kode']], $surat);
        }

        SiteSetting::set('bank_sampah_jadwal', 'Jumat Minggu Pertama & Jumat Minggu Ketiga');
        SiteSetting::set('bank_sampah_foto_harga', 'bank-sampah/foto-harga-bsi.jpg');
        SiteSetting::set('bank_sampah_ketua', 'Bu Wiwik Yatmiati (085790550534)');
        SiteSetting::set('bank_sampah_wakil', 'Bu Ayuningsih (0895809960108)');
    }
}