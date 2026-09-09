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
            'email' => ['required', 'email', Rule::unique('users', 'email')],
            'alamat' => ['required', 'string'],
            'ktp_photo' => ['required', 'image', 'max:4096'],
            'pas_foto' => ['required', 'image', 'max:4096'],
        ], [
            'username.min' => 'Username minimal 8 karakter.',
            'username.regex' => 'Username tidak boleh mengandung spasi.',
            'username.unique' => 'Username sudah terdaftar.',
            'email.unique' => 'Email sudah terdaftar.',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal.', 'errors' => $validator->errors()], 422);
        }

        $ktpPath = $request->file('ktp_photo')->store('ktp', 'public');
        $pasFotoPath = $request->file('pas_foto')->store('pasfoto', 'public');

        $user = User::create([
            'name' => $request->username,
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'wa' => $request->wa,
            'alamat' => $request->alamat,
            'ktp_photo' => $ktpPath,
            'pas_foto' => $pasFotoPath,
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

        // Hapus token lama supaya tidak menumpuk (opsional, aman untuk 1 sesi aktif per device)
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
