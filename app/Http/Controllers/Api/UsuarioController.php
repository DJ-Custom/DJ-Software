<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsuarioController extends Controller
{
    public function index()
    {
        $usuarios = DB::table('usuarios')
            ->join('roles', 'usuarios.rol_id', '=', 'roles.id')
            ->select(
                'usuarios.id', 'usuarios.nombre', 'usuarios.email', 'usuarios.activo',
                'usuarios.ultimo_login', 'usuarios.theme_mode', 'usuarios.intentos_fallidos',
                'usuarios.bloqueado_hasta', 'usuarios.created_at', 'usuarios.modulos_acceso',
                'roles.nombre as rol_nombre', 'roles.id as rol_id'
            )
            ->orderBy('usuarios.nombre')
            ->get();

        return response()->json(['usuarios' => $usuarios]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100',
            'email' => 'required|email|unique:usuarios,email',
            'password' => 'required|string|min:6',
            'rol_id' => 'required|integer',
        ]);

        $lockKey = $this->generateLockKey('crear_usuario', [
            'user' => $request->user()?->id,
            'email' => $request->email,
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $user = User::create([
                'nombre' => $request->nombre,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'rol_id' => $request->rol_id,
                'modulos_acceso' => $request->modulos_acceso,
                'activo' => $request->activo ?? 1,
            ]);

            return response()->json(['success' => true, 'usuario' => $user, 'message' => 'Usuario creado']);
        }, response()->json(['error' => 'Ya se está procesando la creación de este usuario. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $usuario = DB::table('usuarios')
            ->join('roles', 'usuarios.rol_id', '=', 'roles.id')
            ->where('usuarios.id', $id)
            ->select('usuarios.*', 'roles.nombre as rol_nombre')
            ->first();

        if (!$usuario) return response()->json(['error' => 'No encontrado'], 404);
        unset($usuario->password);

        $sesiones = DB::table('sesiones_log')
            ->where('usuario_id', $id)
            ->orderByDesc('created_at')
            ->limit(20)
            ->get();

        $auditoria = DB::table('auditoria')
            ->where('usuario_id', $id)
            ->orderByDesc('created_at')
            ->limit(30)
            ->get();

        $ventasMes = DB::table('ventas')
            ->where('usuario_id', $id)
            ->where('estado', 'completada')
            ->whereMonth('created_at', now()->month)
            ->selectRaw('COUNT(*) as total, COALESCE(SUM(total),0) as monto')
            ->first();

        return response()->json([
            'usuario' => $usuario,
            'sesiones' => $sesiones,
            'auditoria' => $auditoria,
            'ventas_mes' => $ventasMes,
        ]);
    }

    public function update(Request $request, $id)
    {
        $user = User::find($id);
        if (!$user) return response()->json(['error' => 'No encontrado'], 404);

        $data = $request->only(['nombre', 'email', 'rol_id', 'activo', 'modulos_acceso']);
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);
        return response()->json(['success' => true, 'message' => 'Usuario actualizado']);
    }

    public function toggle($id)
    {
        $user = User::find($id);
        if (!$user) return response()->json(['error' => 'No encontrado'], 404);

        $user->update(['activo' => !$user->activo]);
        return response()->json(['success' => true, 'activo' => $user->activo]);
    }

    public function roles()
    {
        $roles = Role::all();
        return response()->json(['roles' => $roles]);
    }

    public function estadisticas()
    {
        $total = User::count();
        $activos = User::where('activo', 1)->count();
        $por_rol = DB::table('usuarios')
            ->join('roles', 'usuarios.rol_id', '=', 'roles.id')
            ->selectRaw('roles.nombre, COUNT(*) as total')
            ->groupBy('roles.nombre')
            ->pluck('total', 'roles.nombre');

        return response()->json(['total' => $total, 'activos' => $activos, 'por_rol' => $por_rol]);
    }
}
