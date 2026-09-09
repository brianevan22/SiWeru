<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('alur_pelayanans', function (Blueprint $table) {
            $table->id();
            $table->string('judul_langkah'); // "Masyarakat", "Kelurahan Memeriksa", dst
            $table->text('deskripsi');
            $table->unsignedInteger('urutan')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('alur_pelayanans');
    }
};
