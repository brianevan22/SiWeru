<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nama')->nullable()->after('name');
            $table->string('wa', 20)->nullable()->after('email');
            $table->text('alamat')->nullable()->after('wa');
            $table->string('ktp_photo')->nullable()->after('alamat');
            $table->string('pas_foto')->nullable()->after('ktp_photo');
            $table->enum('ktp_status', ['unverified', 'valid', 'invalid'])
                ->default('unverified')
                ->after('pas_foto');
            $table->enum('role', ['warga', 'admin'])->default('warga')->after('ktp_status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['nama', 'wa', 'alamat', 'ktp_photo', 'pas_foto', 'ktp_status', 'role']);
        });
    }
};
