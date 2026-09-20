<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Kolom dokumen_pendukung sebelumnya bertipe JSON (longtext + CHECK
     * json_valid), padahal isinya cuma satu path file string biasa.
     * Ubah jadi VARCHAR supaya path file bisa disimpan.
     *
     * Pakai raw SQL, bukan ->change(), karena mengubah dari/ke JSON
     * sering gagal lewat Blueprint di MySQL/MariaDB.
     */
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE `surat_pengajuans`
             MODIFY `dokumen_pendukung` VARCHAR(255) NOT NULL"
        );
    }

    public function down(): void
    {
        DB::statement(
            "ALTER TABLE `surat_pengajuans`
             MODIFY `dokumen_pendukung` LONGTEXT
             CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
             CHECK (json_valid(`dokumen_pendukung`))"
        );
    }
};