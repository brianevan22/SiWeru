<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surat_pengajuans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('jenis_surat'); // SKCK, KEMATIAN, SKTM, USAHA, DOMISILI, dll
            $table->text('keperluan');
            $table->json('dokumen_pendukung'); // path file upload warga
            $table->enum('status', ['diproses', 'selesai', 'ditolak'])->default('diproses');
            $table->string('file_hasil')->nullable(); // path PDF hasil dari admin
            $table->text('catatan_admin')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surat_pengajuans');
    }
};
