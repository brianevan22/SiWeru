<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('info_surat_settings', function (Blueprint $table) {
            if (! Schema::hasColumn('info_surat_settings', 'gambar_posyandu')) {
                $table->string('gambar_posyandu')->nullable()->after('gambar_syarat');
            }
        });
    }

    public function down(): void
    {
        Schema::table('info_surat_settings', function (Blueprint $table) {
            if (Schema::hasColumn('info_surat_settings', 'gambar_posyandu')) {
                $table->dropColumn('gambar_posyandu');
            }
        });
    }
};