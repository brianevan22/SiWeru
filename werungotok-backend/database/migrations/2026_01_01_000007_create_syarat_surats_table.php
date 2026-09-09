<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('syarat_surats', function (Blueprint $table) {
            $table->id();
            $table->string('nama_surat'); // Surat Kematian, SKCK, SKTM, Keterangan Usaha
            $table->json('daftar_syarat'); // ["Pengantar RT/RW (WAJIB)", ...]
            $table->unsignedInteger('urutan')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('syarat_surats');
    }
};
