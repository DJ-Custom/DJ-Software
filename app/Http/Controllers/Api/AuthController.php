<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['error' => 'Credenciales incorrectas'], 401);
        }

        if (!$user->activo) {
            return response()->json(['error' => 'Tu cuenta está desactivada. Contacta al administrador.'], 403);
        }

        if ($user->bloqueado_hasta && now()->lt($user->bloqueado_hasta)) {
            return response()->json(['error' => 'Cuenta bloqueada temporalmente. Intenta más tarde.'], 403);
        }

        if (!Hash::check($request->password, $user->password)) {
            $user->increment('intentos_fallidos');

            if ($user->intentos_fallidos >= 5) {
                $user->update(['bloqueado_hasta' => now()->addMinutes(15)]);
            }

            return response()->json(['error' => 'Credenciales incorrectas'], 401);
        }

        // ── Single-session enforcement ──────────────────────────────────
        // Close any orphaned active sessions (beacon failed, crash, etc.)
        $orphaned = DB::table('productividad_sesiones')
            ->where('usuario_id', $user->id)
            ->whereNull('fin_sesion')
            ->get();

        foreach ($orphaned as $sesion) {
            $tiempoActivo = (int) ($sesion->tiempo_activo ?? 0);
            if (!(bool) ($sesion->en_pausa ?? false) && $sesion->ultima_actividad) {
                $ultimaTs = \Carbon\Carbon::parse($sesion->ultima_actividad);
                $diff = (int) $ultimaTs->diffInSeconds(now());
                if ($diff > 0 && $diff <= 300) {
                    $tiempoActivo += $diff;
                }
            }
            DB::table('productividad_sesiones')->where('id', $sesion->id)->update([
                'fin_sesion' => now(),
                'duracion_minutos' => (int) ceil($tiempoActivo / 60),
                'tiempo_activo' => $tiempoActivo,
                'en_pausa' => true,
            ]);
        }

        // Also delete stale Sanctum tokens from other devices
        $user->tokens()->delete();
        // ─────────────────────────────────────────────────────────────────

        // Reset failed attempts
        $user->update([
            'intentos_fallidos' => 0,
            'bloqueado_hasta' => null,
            'ultimo_login' => now(),
        ]);

        // Load role
        $user->load('rol');

        // Create Sanctum token
        $token = $user->createToken('auth-token')->plainTextToken;

        // Log session
        DB::table('sesiones_log')->insert([
            'usuario_id' => $user->id,
            'accion' => 'login',
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'created_at' => now(),
        ]);

        $rolPermisos = $user->rol->permisos ?? [];
        $userModulos = $user->modulos_acceso ?? [];
        $modulosAcceso = array_values(array_unique(array_merge(
            is_array($rolPermisos) ? $rolPermisos : json_decode($rolPermisos, true) ?? [],
            is_array($userModulos) ? $userModulos : json_decode($userModulos, true) ?? []
        )));

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'nombre' => $user->nombre,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'theme_mode' => $user->theme_mode ?? 'light',
                'rol_id' => $user->rol_id,
                'rol_nombre' => $user->rol->nombre ?? '',
                'modulos_acceso' => $modulosAcceso,
                'permisos' => $modulosAcceso,
            ],
            'message' => 'Inicio de sesión exitoso',
        ]);
    }

    public function logout(Request $request)
    {
        DB::table('sesiones_log')->insert([
            'usuario_id' => $request->user()->id,
            'accion' => 'logout',
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'created_at' => now(),
        ]);

        // Close active productivity session
        $this->cerrarProductividad($request->user()->id);

        $request->user()->currentAccessToken()->delete();

        return response()->json(['success' => true, 'message' => 'Sesión cerrada']);
    }

    public function check(Request $request)
    {
        $user = $request->user();
        $user->load('rol');

        $rolPermisos = $user->rol->permisos ?? [];
        $userModulos = $user->modulos_acceso ?? [];
        $modulosAcceso = array_values(array_unique(array_merge(
            is_array($rolPermisos) ? $rolPermisos : json_decode($rolPermisos, true) ?? [],
            is_array($userModulos) ? $userModulos : json_decode($userModulos, true) ?? []
        )));

        return response()->json([
            'authenticated' => true,
            'user' => [
                'id' => $user->id,
                'nombre' => $user->nombre,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'theme_mode' => $user->theme_mode ?? 'light',
                'rol_id' => $user->rol_id,
                'rol_nombre' => $user->rol->nombre ?? '',
                'modulos_acceso' => $modulosAcceso,
                'permisos' => $modulosAcceso,
            ],
        ]);
    }

    public function toggleTheme(Request $request)
    {
        $user = $request->user();
        $newTheme = $user->theme_mode === 'dark' ? 'light' : 'dark';
        $user->update(['theme_mode' => $newTheme]);

        return response()->json(['success' => true, 'theme' => $newTheme]);
    }

    public function invalidateToken(Request $request)
    {
        $token = $request->input('token');
        if (!$token) {
            return response()->json(['error' => 'Token required'], 400);
        }

        $tokenHash = hash('sha256', $token);
        $accessToken = DB::table('personal_access_tokens')
            ->where('token', $tokenHash)
            ->first();

        if ($accessToken) {
            // Close productivity session for this user
            $this->cerrarProductividad($accessToken->tokenable_id);

            DB::table('personal_access_tokens')
                ->where('id', $accessToken->id)
                ->delete();
        }

        return response()->json(['success' => true]);
    }

    private function cerrarProductividad(int $userId): void
    {
        $activas = DB::table('productividad_sesiones')
            ->where('usuario_id', $userId)
            ->whereNull('fin_sesion')
            ->get();

        $ahora = now();
        foreach ($activas as $activa) {
            $this->cerrarSesionInterna($activa, $ahora);
            $this->actualizarResumen($userId, $activa);
        }
    }

    private function cerrarSesionInterna($sesion, $ahora): void
    {
        $tiempoActivo = (int) ($sesion->tiempo_activo ?? 0);
        $enPausa = (bool) ($sesion->en_pausa ?? false);

        if (!$enPausa && $sesion->ultima_actividad) {
            $ultimaTs = \Carbon\Carbon::parse($sesion->ultima_actividad);
            $diff = (int) $ultimaTs->diffInSeconds($ahora);
            if ($diff > 0 && $diff <= 300) {
                $tiempoActivo += $diff;
            }
        }

        $minutos = (int) ceil($tiempoActivo / 60);

        DB::table('productividad_sesiones')->where('id', $sesion->id)->update([
            'fin_sesion' => $ahora,
            'duracion_minutos' => $minutos,
            'tiempo_activo' => $tiempoActivo,
            'en_pausa' => true,
        ]);

        $sesion->duracion_minutos = $minutos;
        $sesion->tiempo_activo = $tiempoActivo;
        $sesion->en_pausa = true;
    }

    private function actualizarResumen(int $userId, $sesion): void
    {
        $fecha = \Carbon\Carbon::parse($sesion->inicio_sesion)->toDateString();
        $minutos = (int) ($sesion->duracion_minutos ?? 0);

        if ($minutos <= 0) {
            $minutos = (int) ceil(((int) ($sesion->tiempo_activo ?? 0)) / 60);
        }

        if ($minutos <= 0) {
            return;
        }

        $ventas = DB::table('ventas')
            ->where('usuario_id', $userId)
            ->where('created_at', '>=', $sesion->inicio_sesion)
            ->where('estado', '!=', 'cancelada')
            ->selectRaw('COALESCE(SUM(total), 0) as total_ventas, COUNT(*) as cantidad')
            ->first();

        $ventasTotal = $ventas->total_ventas ?? 0;
        $ventasCount = $ventas->cantidad ?? 0;

        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $fecha, 'periodo' => 'dia'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        $semanaInicio = \Carbon\Carbon::parse($fecha)->startOfWeek()->toDateString();
        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $semanaInicio, 'periodo' => 'semana'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        $mesInicio = \Carbon\Carbon::parse($fecha)->startOfMonth()->toDateString();
        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => $mesInicio, 'periodo' => 'mes'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );

        DB::table('productividad_resumen')->updateOrInsert(
            ['usuario_id' => $userId, 'fecha' => '1970-01-01', 'periodo' => 'historico'],
            [
                'total_minutos' => DB::raw("total_minutos + {$minutos}"),
                'total_sesiones' => DB::raw('total_sesiones + 1'),
                'ventas_generadas' => DB::raw("ventas_generadas + {$ventasTotal}"),
                'cantidad_ventas' => DB::raw("cantidad_ventas + {$ventasCount}"),
                'updated_at' => now(),
            ]
        );
    }
}
