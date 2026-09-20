<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JenisSurat;
use App\Models\SuratPengajuan;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class SuratController extends Controller
{
    public function jenisSurat()
    {
        return response()->json([
            'data' => JenisSurat::where('is_active', true)
                ->orderBy('nama_surat')
                ->get(),
        ]);
    }

    public function statusKtp(Request $request)
    {
        $user = $request->user();
        $catatan = $user->ktp_catatan;

        return response()->json([
            'ktp_status' => $user->ktp_status,
            'boleh_mengajukan' => $user->ktp_status === 'valid' || $user->isAdmin(),
            'catatan' => $catatan,
            'pesan' => match ($user->ktp_status) {
                'valid' => 'KTP terverifikasi, silakan ajukan surat.',
                'invalid' => ($catatan !== null && trim($catatan) !== '')
                    ? $catatan
                    : 'Foto KTP buram atau tidak sesuai dengan alamat Werungotok.',
                default => 'KTP sedang diverifikasi admin untuk pengajuan surat, tunggu paling lama 24 jam.',
            },
        ]);
    }

    /**
     * Riwayat pengajuan warga yang login, dilengkapi nama surat
     * (bukan hanya kode) agar mudah dibaca.
     */
    public function index(Request $request)
    {
        $surat = $request->user()->suratPengajuans()->latest()->get();
        $map = JenisSurat::pluck('nama_surat', 'kode');

        $data = $surat->map(function ($s) use ($map) {
            $arr = $s->toArray();
            $arr['nama_surat'] = $map[$s->jenis_surat] ?? $s->jenis_surat;
            return $arr;
        });

        return response()->json(['data' => $data]);
    }

    public function show(Request $request, SuratPengajuan $surat)
    {
        if ($surat->user_id !== $request->user()->id && ! $request->user()->isAdmin()) {
            return response()->json(['message' => 'Tidak diizinkan.'], 403);
        }

        $arr = $surat->toArray();
        $arr['nama_surat'] = JenisSurat::where('kode', $surat->jenis_surat)
            ->value('nama_surat') ?? $surat->jenis_surat;

        return response()->json(['data' => $arr]);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->ktp_status !== 'valid' && ! $user->isAdmin()) {
            return response()->json([
                'message' => 'KTP Anda belum terverifikasi. Tidak bisa mengajukan surat.',
            ], 403);
        }

        $kodeValid = JenisSurat::pluck('kode')->all();

        $validator = Validator::make($request->all(), [
            'jenis_surat' => ['required', 'string', Rule::in($kodeValid)],
            'keperluan' => ['required', 'string', 'max:1000'],
            'dokumen_pendukung' => ['required', 'file', 'mimes:pdf', 'max:4096'],
            'client_time' => ['required', 'date'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        // Cegah manipulasi waktu: waktu perangkat harus dekat dengan waktu server.
        $selisih = abs(Carbon::now()->diffInSeconds(Carbon::parse($request->client_time)));
        if ($selisih > 300) { // toleransi 5 menit
            return response()->json([
                'message' => 'Waktu perangkat tidak sesuai. Aktifkan tanggal & jam otomatis, lalu coba lagi.',
            ], 422);
        }

        $path = $request->file('dokumen_pendukung')->store('surat/dokumen_pendukung', 'public');

        $surat = SuratPengajuan::create([
            'user_id' => $user->id,
            'jenis_surat' => $request->jenis_surat,
            'keperluan' => $request->keperluan,
            'dokumen_pendukung' => $path,
            'status' => 'diproses',
        ]);

        return response()->json([
            'message' => 'Proses pengajuan surat berhasil, menunggu proses validasi.',
            'data' => $surat,
        ], 201);
    }
}