<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jenis_sampahs', function (Blueprint $table) {
            $table->id();
            $table->string('nama'); // Botol Plastik, Kardus & Kertas, dst
            $table->string('icon')->nullable(); // nama ikon (fontawesome di web / dipetakan di flutter)
            $table->unsignedInteger('urutan')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jenis_sampahs');
    }
};
