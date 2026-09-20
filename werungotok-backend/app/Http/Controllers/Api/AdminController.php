<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JenisSurat;
use App\Models\SuratPengajuan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{
    /**
     * Daftar warga + riwayat surat tiap warga (dengan nama surat).
     */
    public function listWarga()
    {
        $warga = User::where('role', 'warga')
            ->with(['suratPengajuans' => fn ($q) => $q->latest()])
            ->latest()
            ->get();

        $map = JenisSurat::pluck('nama_surat', 'kode');

        $data = $warga->map(function ($w) use ($map) {
            $arr = $w->toArray();
            if (isset($arr['surat_pengajuans'])) {
                $arr['surat_pengajuans'] = collect($arr['surat_pengajuans'])
                    ->map(function ($s) use ($map) {
                        $s['nama_surat'] = $map[$s['jenis_surat']] ?? $s['jenis_surat'];
                        return $s;
                    })->all();
            }
            return $arr;
        });

        return response()->json(['data' => $data]);
    }

    public function verifikasiWarga(Request $request, User $warga)
    {
        $validator = Validator::make($request->all(), [
            'ktp_status' => ['required', 'in:valid,invalid'],
            'catatan' => ['nullable', 'string', 'max:500'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        // Assign langsung agar tidak bergantung pada $fillable.
        $warga->ktp_status = $request->ktp_status;
        $warga->ktp_catatan =
            $request->ktp_status === 'invalid' ? $request->catatan : null;
        $warga->save();

        return response()->json([
            'message' => 'Status KTP diperbarui!',
            'data' => $warga,
        ]);
    }

    /**
     * Daftar semua permohonan surat + data pemohon + nama surat.
     */
    public function listSurat(Request $request)
    {
        $query = SuratPengajuan::with([
            'user:id,name,nama,wa,alamat,foto_profil,ktp_photo,ktp_status',
        ])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $list = $query->get();
        $map = JenisSurat::pluck('nama_surat', 'kode');

        $data = $list->map(function ($s) use ($map) {
            $arr = $s->toArray();
            $arr['nama_surat'] = $map[$s->jenis_surat] ?? $s->jenis_surat;
            return $arr;
        });

        return response()->json(['data' => $data]);
    }

    public function prosesSurat(Request $request, SuratPengajuan $surat)
    {
        $validator = Validator::make($request->all(), [
            'status' => ['required', 'in:selesai,ditolak'],
            'catatan_admin' => ['nullable', 'string'],
            'file_hasil' => ['required_if:status,selesai', 'nullable', 'file', 'mimes:pdf', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $data = [
            'status' => $request->status,
            'catatan_admin' => $request->catatan_admin,
        ];

        if ($request->hasFile('file_hasil')) {
            $data['file_hasil'] = $request->file('file_hasil')->store('surat/hasil', 'public');
        }

        $surat->update($data);

        return response()->json([
            'message' => 'Surat berhasil dikirim ke warga!',
            'data' => $surat->fresh(),
        ]);
    }
}