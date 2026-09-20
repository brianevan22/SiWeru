<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/storage/{path}', function ($path) {
    // Memetakan request dari 'pasfoto/' ke 'foto_profil/' secara otomatis
    $adjustedPath = str_replace('pasfoto/', 'foto_profil/', $path);

    if (!Storage::disk('public')->exists($adjustedPath)) {
        abort(404);
    }

    return Storage::disk('public')->response($adjustedPath, 200, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
    ]);
})->where('path', '.*');