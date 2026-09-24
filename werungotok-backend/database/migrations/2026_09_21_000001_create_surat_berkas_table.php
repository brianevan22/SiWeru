<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surat_berkas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('surat_pengajuan_id')
                ->constrained('surat_pengajuans')
                ->onDelete('cascade');
            $table->string('syarat_key');   // mis. pengantar_rt, fc_kk
            $table->string('file_path');    // lokasi file tersimpan
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surat_berkas');
    }
};