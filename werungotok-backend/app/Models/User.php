<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'nama',
        'email',
        'password',
        'wa',
        'alamat',
        'ktp_photo',
        'pas_foto',
        'ktp_status',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function suratPengajuans()
    {
        return $this->hasMany(SuratPengajuan::class);
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }
}
