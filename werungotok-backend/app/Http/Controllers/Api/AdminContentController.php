<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AlurPelayanan;
use App\Models\InfoSuratSetting;
use App\Models\JenisSurat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

/**
 * Pengelolaan konten oleh admin: CRUD jenis surat, langkah alur,
 * serta gambar halaman Informasi Surat.
 */
class AdminContentController extends Controller
{
    // ============ JENIS SURAT (CRUD) ============

    public function jenisIndex()
    {
        return response()->json([
            'data' => JenisSurat::orderBy('nama_surat')->get(),
        ]);
    }

    public function jenisStore(Request $request)
    {
        $data = $this->validateJenis($request);
        if ($data instanceof JsonResponse) return $data;

        // Kode dibuat otomatis dari nama surat, dijamin unik.
        $data['kode'] = $this->generateKode($data['nama_surat']);

        $jenis = JenisSurat::create($data);

        return response()->json(
            ['message' => 'Surat ditambahkan.', 'data' => $jenis],
            201
        );
    }

    public function jenisUpdate(Request $request, JenisSurat $jenis)
    {
        $data = $this->validateJenis($request);
        if ($data instanceof JsonResponse) return $data;

        // Kode TIDAK diubah saat edit, agar pengajuan lama tetap cocok.
        $jenis->update($data);

        return response()->json(
            ['message' => 'Surat diperbarui.', 'data' => $jenis]
        );
    }

    public function jenisDestroy(JenisSurat $jenis)
    {
        $jenis->delete();

        return response()->json(['message' => 'Surat dihapus.']);
    }

    /**
     * Validasi + normalisasi input jenis surat (tanpa kode).
     * syarat_required boleh dikirim sebagai JSON string (dari multipart).
     */
    private function validateJenis(Request $request)
    {
        $raw = $request->input('syarat_required', '[]');
        $syarat = is_array($raw) ? $raw : (json_decode($raw, true) ?: []);
        $request->merge(['syarat_required' => $syarat]);

        $validator = Validator::make($request->all(), [
            'nama_surat' => ['required', 'string', 'max:255'],
            'keterangan' => ['nullable', 'string', 'max:2000'],
            'perlu_materai' => ['nullable'],
            'syarat_required' => ['array'],
            'syarat_required.*' => ['string', 'max:255'],
            'is_active' => ['nullable'],
        ]);

        if ($validator->fails()) {
            return response()->json(
                ['message' => 'Validasi gagal.', 'errors' => $validator->errors()],
                422
            );
        }

        return [
            'nama_surat' => $request->nama_surat,
            'keterangan' => $request->keterangan,
            'perlu_materai' => $request->boolean('perlu_materai', false),
            'syarat_required' => array_values(array_filter(
                $syarat,
                fn ($s) => trim((string) $s) !== ''
            )),
            'is_active' => $request->boolean('is_active', true),
        ];
    }

    /**
     * Buat kode berawalan "SK_" dari nama surat, mengikuti pola data lama
     * (mis. "Surat Keterangan Beda Nama" -> "SK_BEDA_NAMA").
     * Kata "Surat" dan "Keterangan" di depan dibuang, sisanya HURUF BESAR
     * dengan "_", lalu ditambah angka bila sudah ada yang sama.
     */
    private function generateKode(string $nama): string
    {
        // Buang kata "surat" / "keterangan" di mana pun, rapikan spasi.
        $inti = preg_replace('/\b(surat|keterangan)\b/i', ' ', $nama);
        $inti = strtoupper(preg_replace('/[^A-Za-z0-9]+/', '_', trim($inti)));
        $inti = trim($inti, '_');
        if ($inti === '') {
            $inti = 'UMUM';
        }

        $base = 'SK_' . $inti;
        $kode = $base;
        $i = 2;
        while (JenisSurat::where('kode', $kode)->exists()) {
            $kode = $base . '_' . $i;
            $i++;
        }

        return $kode;
    }

    // ============ ALUR PELAYANAN (langkah 1-5) ============

    public function alurStore(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'judul_langkah' => ['required', 'string', 'max:255'],
            'deskripsi' => ['required', 'string', 'max:2000'],
        ]);
        if ($validator->fails()) {
            return response()->json(
                ['message' => 'Validasi gagal.', 'errors' => $validator->errors()],
                422
            );
        }

        $urutan = (int) (AlurPelayanan::max('urutan') ?? 0) + 1;
        $alur = AlurPelayanan::create([
            'judul_langkah' => $request->judul_langkah,
            'deskripsi' => $request->deskripsi,
            'urutan' => $urutan,
        ]);

        return response()->json(
            ['message' => 'Langkah ditambahkan.', 'data' => $alur],
            201
        );
    }

    public function alurUpdate(Request $request, AlurPelayanan $alur)
    {
        $validator = Validator::make($request->all(), [
            'judul_langkah' => ['required', 'string', 'max:255'],
            'deskripsi' => ['required', 'string', 'max:2000'],
        ]);
        if ($validator->fails()) {
            return response()->json(
                ['message' => 'Validasi gagal.', 'errors' => $validator->errors()],
                422
            );
        }

        $alur->update([
            'judul_langkah' => $request->judul_langkah,
            'deskripsi' => $request->deskripsi,
        ]);

        return response()->json(['message' => 'Langkah diperbarui.', 'data' => $alur]);
    }

    public function alurDestroy(AlurPelayanan $alur)
    {
        $alur->delete();

        return response()->json(['message' => 'Langkah dihapus.']);
    }

    // ============ INFO SURAT (gambar & keterangan) ============

    public function infoShow()
    {
        $s = InfoSuratSetting::firstOrCreate(['id' => 1]);

        return response()->json(['data' => [
            'keterangan' => $s->keterangan,
            'gambar_alur' => $s->gambar_alur,
            'gambar_syarat' => $s->gambar_syarat,
            'gambar_posyandu' => $s->gambar_posyandu,
        ]]);
    }

    public function infoUpdate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'keterangan' => ['nullable', 'string', 'max:2000'],
            'gambar_alur' => ['nullable', 'file', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
            'gambar_syarat' => ['nullable', 'file', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
            'gambar_posyandu' => ['nullable', 'file', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return response()->json(
                ['message' => 'Validasi gagal.', 'errors' => $validator->errors()],
                422
            );
        }

        $s = InfoSuratSetting::firstOrCreate(['id' => 1]);

        if ($request->has('keterangan')) {
            $s->keterangan = $request->keterangan;
        }

        if ($request->hasFile('gambar_alur')) {
            if ($s->gambar_alur && Storage::disk('public')->exists($s->gambar_alur)) {
                Storage::disk('public')->delete($s->gambar_alur);
            }
            $s->gambar_alur = $request->file('gambar_alur')->store('info_surat', 'public');
        }

        if ($request->hasFile('gambar_syarat')) {
            if ($s->gambar_syarat && Storage::disk('public')->exists($s->gambar_syarat)) {
                Storage::disk('public')->delete($s->gambar_syarat);
            }
            $s->gambar_syarat = $request->file('gambar_syarat')->store('info_surat', 'public');
        }

        if ($request->hasFile('gambar_posyandu')) {
            if ($s->gambar_posyandu && Storage::disk('public')->exists($s->gambar_posyandu)) {
                Storage::disk('public')->delete($s->gambar_posyandu);
            }
            $s->gambar_posyandu = $request->file('gambar_posyandu')->store('info_surat', 'public');
        }

        $s->save();

        return response()->json(['message' => 'Info surat diperbarui.', 'data' => [
            'keterangan' => $s->keterangan,
            'gambar_alur' => $s->gambar_alur,
            'gambar_syarat' => $s->gambar_syarat,
            'gambar_posyandu' => $s->gambar_posyandu,
        ]]);
    }
}