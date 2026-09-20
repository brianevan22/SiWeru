<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('jenis_surats', function (Blueprint $table) {
            $table->id();
            $table->string('kode')->unique(); // Contoh: SK_BELUM_MENIKAH
            $table->string('nama_surat');    // Contoh: Surat Keterangan Belum Menikah
            $table->json('syarat_required'); // Array daftar syarat wajib
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jenis_surats');
    }
};
    