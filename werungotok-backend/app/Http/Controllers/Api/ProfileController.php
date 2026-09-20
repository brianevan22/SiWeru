<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }

    /**
     * Sesuai template: hanya nomor WhatsApp yang bisa diubah warga sendiri.
     * Nama, alamat, email tetap mengikuti data KTP saat registrasi.
     */
    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'wa' => ['required', 'string', 'max:20'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $user->update(['wa' => $request->wa]);

        return response()->json([
            'message' => 'Nomor WhatsApp berhasil diperbarui!',
            'user' => $user,
        ]);
    }

    /**
     * Ganti foto profil. Dipanggil lewat POST /profile/foto (multipart).
     * Foto lama dihapus agar tidak menumpuk di storage.
     */
    public function updateFoto(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'foto_profil' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();

        if ($user->foto_profil && Storage::disk('public')->exists($user->foto_profil)) {
            Storage::disk('public')->delete($user->foto_profil);
        }

        $path = $request->file('foto_profil')->store('foto_profil', 'public');
        // Assign langsung supaya tidak bergantung pada $fillable.
        $user->foto_profil = $path;
        $user->save();

        return response()->json([
            'message' => 'Foto profil berhasil diperbarui!',
            'user' => $user,
        ]);
    }

    /**
     * Warga mengunggah ulang foto KTP (mis. setelah ditolak admin).
     * Status kembali ke 'unverified' dan catatan penolakan dihapus.
     */
    public function updateKtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ktp_photo' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();

        if ($user->ktp_photo && Storage::disk('public')->exists($user->ktp_photo)) {
            Storage::disk('public')->delete($user->ktp_photo);
        }

        $user->ktp_photo = $request->file('ktp_photo')->store('ktp', 'public');
        $user->ktp_status = 'unverified';
        $user->ktp_catatan = null;
        $user->save();

        return response()->json([
            'message' => 'KTP berhasil diunggah ulang. Menunggu verifikasi admin.',
            'user' => $user,
        ]);
    }
}