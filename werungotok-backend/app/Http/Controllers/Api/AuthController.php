<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    /**
     * Registrasi warga baru.
     * Username disimpan di kolom `name` (unik), nama asli KTP di kolom `nama`.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => ['required', 'string', 'min:8', 'regex:/^\S+$/', Rule::unique('users', 'name')],
            'password' => ['required', 'string', 'min:8'],
            'nama' => ['required', 'string', 'max:255'],
            'wa' => ['required', 'string', 'max:20'],
            'email' => ['required', 'email', 'regex:/@gmail\.com$/i', Rule::unique('users', 'email')],
            'alamat' => ['required', 'string'],
            'ktp_photo' => ['required', 'image', 'max:4096'],
            'foto_profil' => ['required', 'image', 'max:4096'],
        ], [
            // Pesan validasi berbahasa Indonesia yang ramah.
            'required' => 'Kolom ini wajib diisi.',
            'username.min' => 'Username minimal 8 karakter.',
            'username.regex' => 'Username tidak boleh mengandung spasi.',
            'username.unique' => 'Username sudah terdaftar. Silakan buat username lain.',
            'password.min' => 'Password minimal 8 karakter.',
            'nama.required' => 'Nama lengkap wajib diisi.',
            'wa.required' => 'Nomor WhatsApp wajib diisi.',
            'wa.max' => 'Nomor WhatsApp terlalu panjang.',
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Format email tidak valid.',
            'email.regex' => 'Email harus menggunakan @gmail.com.',
            'email.unique' => 'Email sudah terdaftar.',
            'alamat.required' => 'Alamat wajib diisi.',
            'ktp_photo.required' => 'Foto KTP wajib diunggah.',
            'ktp_photo.image' => 'Foto KTP harus berupa gambar.',
            'ktp_photo.max' => 'Ukuran foto KTP maksimal 4 MB.',
            'foto_profil.required' => 'Foto profil wajib diunggah.',
            'foto_profil.image' => 'Foto profil harus berupa gambar.',
            'foto_profil.max' => 'Ukuran foto profil maksimal 4 MB.',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $ktpPath = $request->file('ktp_photo')->store('ktp', 'public');
        $fotoProfilPath = $request->file('foto_profil')->store('foto_profil', 'public');

        $user = User::create([
            'name' => $request->username,
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'wa' => $request->wa,
            'alamat' => $request->alamat,
            'ktp_photo' => $ktpPath,
            'foto_profil' => $fotoProfilPath,
            'ktp_status' => 'unverified',
            'role' => 'warga',
        ]);

        return response()->json([
            'message' => 'Pendaftaran berhasil! Silakan login. KTP Anda akan diverifikasi admin.',
            'user' => $user,
        ], 201);
    }

    /**
     * Login warga / admin. Mengembalikan token Sanctum untuk dipakai Flutter.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => ['required', 'string'],
            'password' => ['required', 'string'],
        ], [
            'required' => 'Kolom ini wajib diisi.',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $user = User::where('name', $request->username)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Gagal login! Username tidak terdaftar atau password salah.',
            ], 401);
        }

        $token = $user->createToken('werungotok-app')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil.',
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }
}