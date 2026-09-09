<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posyandu_jadwals', function (Blueprint $table) {
            $table->id();
            $table->string('nama_posyandu'); // ILP BULAKMOJO, ILP WERU, dst
            $table->string('kategori')->nullable(); // untuk badge warna di frontend (ilp/lansia/kader/imunisasi)
            $table->unsignedTinyInteger('jan')->nullable();
            $table->unsignedTinyInteger('feb')->nullable();
            $table->unsignedTinyInteger('mar')->nullable();
            $table->unsignedTinyInteger('apr')->nullable();
            $table->unsignedTinyInteger('mei')->nullable();
            $table->unsignedTinyInteger('jun')->nullable();
            $table->unsignedTinyInteger('jul')->nullable();
            $table->unsignedTinyInteger('agu')->nullable();
            $table->unsignedTinyInteger('sep')->nullable();
            $table->unsignedTinyInteger('okt')->nullable();
            $table->unsignedTinyInteger('nop')->nullable();
            $table->unsignedTinyInteger('des')->nullable();
            $table->unsignedInteger('urutan')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('posyandu_jadwals');
    }
};
