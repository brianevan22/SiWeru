<?php

use App\Http\Controllers\Api\AdminContentController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\InfoSuratController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\SuratController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Werungotok
|--------------------------------------------------------------------------
| Semua route berawalan /api/... (base_url Flutter nanti tinggal
| menunjuk ke domain + /api).
*/

// ================= PUBLIK (tanpa login) =================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/info-surat/alur', [InfoSuratController::class, 'alur']);
Route::get('/info-surat/syarat', [InfoSuratController::class, 'syarat']);
// Gambar & keterangan halaman Info Surat (diatur admin).
Route::get('/info-surat/settings', [InfoSuratController::class, 'settings']);

// Daftar jenis surat aktif untuk dropdown di form pengajuan & Info Surat.
Route::get('/jenis-surat', [SuratController::class, 'jenisSurat']);

// ================= WARGA / ADMIN (wajib login token Sanctum) =================
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    // Ganti foto profil (multipart) — POST karena upload file.
    Route::post('/profile/foto', [ProfileController::class, 'updateFoto']);
    // Unggah ulang KTP untuk diverifikasi kembali.
    Route::post('/profile/ktp', [ProfileController::class, 'updateKtp']);

    Route::get('/surat/status-ktp', [SuratController::class, 'statusKtp']);
    Route::get('/surat', [SuratController::class, 'index']);
    Route::post('/surat', [SuratController::class, 'store']);
    Route::get('/surat/{surat}', [SuratController::class, 'show']);

    // ================= KHUSUS ADMIN =================
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/warga', [AdminController::class, 'listWarga']);
        Route::post('/warga/{warga}/verifikasi', [AdminController::class, 'verifikasiWarga']);

        Route::get('/surat', [AdminController::class, 'listSurat']);
        Route::post('/surat/{surat}/proses', [AdminController::class, 'prosesSurat']);

        // Kelola jenis surat (CRUD)
        Route::get('/jenis-surat', [AdminContentController::class, 'jenisIndex']);
        Route::post('/jenis-surat', [AdminContentController::class, 'jenisStore']);
        Route::put('/jenis-surat/{jenis}', [AdminContentController::class, 'jenisUpdate']);
        Route::delete('/jenis-surat/{jenis}', [AdminContentController::class, 'jenisDestroy']);

        // Kelola langkah alur pelayanan
        Route::post('/alur', [AdminContentController::class, 'alurStore']);
        Route::put('/alur/{alur}', [AdminContentController::class, 'alurUpdate']);
        Route::delete('/alur/{alur}', [AdminContentController::class, 'alurDestroy']);

        // Kelola gambar & keterangan Info Surat
        Route::get('/info-surat', [AdminContentController::class, 'infoShow']);
        Route::post('/info-surat', [AdminContentController::class, 'infoUpdate']);
    });
});