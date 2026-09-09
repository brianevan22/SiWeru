<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IsAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user() || ! $request->user()->isAdmin()) {
            return response()->json([
                'message' => 'Akses ditolak. Khusus admin kelurahan.',
            ], 403);
        }

        return $next($request);
    }
}
