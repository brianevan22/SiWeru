<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('jenis_surats', function (Blueprint $table) {
            if (! Schema::hasColumn('jenis_surats', 'keterangan')) {
                $table->text('keterangan')->nullable()->after('nama_surat');
            }
        });
    }

    public function down(): void
    {
        Schema::table('jenis_surats', function (Blueprint $table) {
            if (Schema::hasColumn('jenis_surats', 'keterangan')) {
                $table->dropColumn('keterangan');
            }
        });
    }
};