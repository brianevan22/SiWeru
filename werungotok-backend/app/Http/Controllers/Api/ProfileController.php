<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
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
}
