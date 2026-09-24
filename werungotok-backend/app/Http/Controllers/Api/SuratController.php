<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JenisSurat;
use App\Models\SuratBerkas;
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
     * Riwayat pengajuan warga yang login, dilengkapi nama surat & berkas.
     */
    public function index(Request $request)
    {
        $surat = $request->user()->suratPengajuans()
            ->with('berkas')
            ->latest()
            ->get();

        $jenis = JenisSurat::get()->keyBy('kode');

        $data = $surat->map(function ($s) use ($jenis) {
            $arr = $s->toArray();
            $j = $jenis[$s->jenis_surat] ?? null;
            $arr['nama_surat'] = $j->nama_surat ?? $s->jenis_surat;
            $arr['perlu_materai'] = (bool) ($j->perlu_materai ?? false);
            return $arr;
        });

        return response()->json(['data' => $data]);
    }

    public function show(Request $request, SuratPengajuan $surat)
    {
        if ($surat->user_id !== $request->user()->id && ! $request->user()->isAdmin()) {
            return response()->json(['message' => 'Tidak diizinkan.'], 403);
        }

        $surat->load('berkas');
        $j = JenisSurat::where('kode', $surat->jenis_surat)->first();

        $arr = $surat->toArray();
        $arr['nama_surat'] = $j->nama_surat ?? $surat->jenis_surat;
        $arr['perlu_materai'] = (bool) ($j->perlu_materai ?? false);

        return response()->json(['data' => $arr]);
    }

    /**
     * Warga mengajukan surat baru.
     * Berkas diunggah TERPISAH per syarat: field `berkas[nama_syarat]`.
     * Format yang diterima: PDF maupun foto (jpg/jpeg/png).
     */
    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->ktp_status !== 'valid' && ! $user->isAdmin()) {
            return response()->json([
                'message' => 'KTP Anda belum terverifikasi. Tidak bisa mengajukan surat.',
            ], 403);
        }

        $kodeValid = JenisSurat::pluck('kode')->all();

        // Aturan dasar
        $rules = [
            'jenis_surat' => ['required', 'string', Rule::in($kodeValid)],
            'keperluan' => ['required', 'string', 'max:1000'],
            'client_time' => ['required', 'date'],
        ];
        $pesan = [];

        // Aturan berkas mengikuti syarat jenis surat yang dipilih.
        $jenis = JenisSurat::where('kode', $request->jenis_surat)->first();
        $syarat = is_array($jenis?->syarat_required) ? $jenis->syarat_required : [];

        if (count($syarat) > 0) {
            foreach ($syarat as $key) {
                $rules["berkas.$key"] =
                    ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:4096'];
                $label = ucwords(str_replace('_', ' ', $key));
                $pesan["berkas.$key.required"] = "Berkas $label wajib diunggah.";
                $pesan["berkas.$key.mimes"] = "Berkas $label harus PDF atau foto.";
                $pesan["berkas.$key.max"] = "Ukuran berkas $label maksimal 4 MB.";
            }
        } else {
            // Surat tanpa daftar syarat: pakai satu berkas pendukung.
            $rules['dokumen_pendukung'] =
                ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:4096'];
        }

        $validator = Validator::make($request->all(), $rules, $pesan);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        // Cegah manipulasi waktu perangkat.
        $selisih = abs(Carbon::now()->diffInSeconds(Carbon::parse($request->client_time)));
        if ($selisih > 300) {
            return response()->json([
                'message' => 'Waktu perangkat tidak sesuai. Aktifkan tanggal & jam otomatis, lalu coba lagi.',
            ], 422);
        }

        $pathUtama = null;
        if ($request->hasFile('dokumen_pendukung')) {
            $pathUtama = $request->file('dokumen_pendukung')
                ->store('surat/dokumen_pendukung', 'public');
        }

        $surat = SuratPengajuan::create([
            'user_id' => $user->id,
            'jenis_surat' => $request->jenis_surat,
            'keperluan' => $request->keperluan,
            'dokumen_pendukung' => $pathUtama,
            'status' => 'diproses',
        ]);

        // Simpan tiap berkas syarat.
        foreach ($syarat as $key) {
            $file = $request->file("berkas.$key");
            if ($file) {
                SuratBerkas::create([
                    'surat_pengajuan_id' => $surat->id,
                    'syarat_key' => $key,
                    'file_path' => $file->store('surat/berkas', 'public'),
                ]);
            }
        }

        $pesanSukses = 'Proses pengajuan surat berhasil, menunggu proses validasi.';
        if ($jenis && $jenis->perlu_materai) {
            $pesanSukses .= ' Surat ini memerlukan materai — Anda akan dihubungi '
                . 'admin melalui WhatsApp untuk datang ke kelurahan.';
        }

        return response()->json([
            'message' => $pesanSukses,
            'data' => $surat->load('berkas'),
        ], 201);
    }
}