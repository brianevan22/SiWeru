<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SuratPengajuan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SuratController extends Controller
{
    /**
     * Cek status KTP warga sebelum boleh mengajukan surat.
     * Frontend Flutter memanggil ini untuk menentukan tampilan
     * (sama seperti kotak status di surat.html).
     */
    public function statusKtp(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'ktp_status' => $user->ktp_status,
            'boleh_mengajukan' => $user->ktp_status === 'valid' || $user->isAdmin(),
            'pesan' => match ($user->ktp_status) {
                'valid' => 'KTP terverifikasi, silakan ajukan surat.',
                'invalid' => 'Foto KTP buram atau tidak sesuai dengan alamat Werungotok.',
                default => 'KTP sedang diverifikasi admin untuk pengajuan surat, tunggu paling lama 24 jam.',
            },
        ]);
    }

    /**
     * Daftar riwayat pengajuan surat milik warga yang login.
     */
    public function index(Request $request)
    {
        $surat = $request->user()->suratPengajuans()->latest()->get();

        return response()->json(['data' => $surat]);
    }

    public function show(Request $request, SuratPengajuan $surat)
    {
        if ($surat->user_id !== $request->user()->id && ! $request->user()->isAdmin()) {
            return response()->json(['message' => 'Tidak diizinkan.'], 403);
        }

        return response()->json(['data' => $surat]);
    }

    /**
     * Warga mengajukan surat baru. Wajib KTP sudah valid.
     */
    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->ktp_status !== 'valid' && ! $user->isAdmin()) {
            return response()->json([
                'message' => 'KTP Anda belum terverifikasi. Tidak bisa mengajukan surat.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'jenis_surat' => ['required', 'string', 'in:SKCK,KEMATIAN,SKTM,USAHA,DOMISILI,LAINNYA'],
            'dokumen_pendukung' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $path = $request->file('dokumen_pendukung')->store('surat/dokumen_pendukung', 'public');

        $surat = SuratPengajuan::create([
            'user_id' => $user->id,
            'jenis_surat' => $request->jenis_surat,
            'dokumen_pendukung' => $path,
            'status' => 'diproses',
        ]);

        return response()->json([
            'message' => 'Berhasil! Dokumen PDF akan dikirimkan ke WhatsApp Anda.',
            'data' => $surat,
        ], 201);
    }
}
