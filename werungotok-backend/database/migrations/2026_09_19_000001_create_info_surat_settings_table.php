<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('info_surat_settings', function (Blueprint $table) {
            $table->id();
            $table->string('gambar_alur')->nullable();   // path gambar alur
            $table->string('gambar_syarat')->nullable(); // path gambar syarat
            $table->text('keterangan')->nullable();      // catatan tambahan
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('info_surat_settings');
    }
};