<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SuratPengajuan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{
    /**
     * Daftar warga (non-admin) untuk divalidasi KTP-nya.
     */
    public function listWarga()
    {
        $warga = User::where('role', 'warga')->latest()->get();

        return response()->json(['data' => $warga]);
    }

    /**
     * Setujui / tolak KTP warga.
     */
    public function verifikasiWarga(Request $request, User $warga)
    {
        $validator = Validator::make($request->all(), [
            'ktp_status' => ['required', 'in:valid,invalid'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $warga->update(['ktp_status' => $request->ktp_status]);

        return response()->json([
            'message' => 'Status KTP diperbarui!',
            'data' => $warga,
        ]);
    }

    /**
     * Daftar semua permohonan surat dari seluruh warga.
     */
    public function listSurat(Request $request)
    {
        $query = SuratPengajuan::with('user:id,name,nama,wa')->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json(['data' => $query->get()]);
    }

    /**
     * Admin memproses surat: upload PDF hasil jadi & ubah status.
     */
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
