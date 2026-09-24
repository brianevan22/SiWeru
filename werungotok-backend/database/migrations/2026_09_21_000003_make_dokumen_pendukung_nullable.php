<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Berkas kini diunggah terpisah per syarat (tabel surat_berkas),
     * sehingga kolom lama dokumen_pendukung boleh kosong.
     */
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE `surat_pengajuans`
             MODIFY `dokumen_pendukung` VARCHAR(255) NULL"
        );
    }

    public function down(): void
    {
        DB::statement(
            "ALTER TABLE `surat_pengajuans`
             MODIFY `dokumen_pendukung` VARCHAR(255) NOT NULL"
        );
    }
};