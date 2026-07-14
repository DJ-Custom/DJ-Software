<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class SmtpConfigHelper
{
    /**
     * Aplica la configuración SMTP desde la tabla `configuracion`
     * al mailer SMTP de Laravel en tiempo de ejecución.
     *
     * @return bool true si se aplicó correctamente, false si SMTP no está activo
     */
    public static function aplicarConfiguracion(): bool
    {
        $smtpActivo = DB::table('configuracion')->where('clave', 'smtp_activo')->value('valor');

        if ($smtpActivo !== '1') {
            return false;
        }

        $host     = DB::table('configuracion')->where('clave', 'smtp_host')->value('valor') ?? '';
        $port     = DB::table('configuracion')->where('clave', 'smtp_port')->value('valor') ?? '587';
        $username = DB::table('configuracion')->where('clave', 'smtp_username')->value('valor') ?? '';
        $password = DB::table('configuracion')->where('clave', 'smtp_password')->value('valor') ?? '';
        $scheme   = DB::table('configuracion')->where('clave', 'smtp_encryption')->value('valor') ?? 'tls';

        if (empty($host)) {
            return false;
        }

        // Mapear esquema: Laravel acepta "smtp" (STARTTLS) o "smtps" (SSL directo)
        // tls (puerto 587) → "smtp", ssl (puerto 465) → "smtps"
        $mailerScheme = $scheme === 'ssl' ? 'smtps' : 'smtp';

        // Reconfigurar el mailer SMTP en tiempo de ejecución
        config([
            'mail.default'               => 'smtp',
            'mail.mailers.smtp.host'     => $host,
            'mail.mailers.smtp.port'     => (int) $port,
            'mail.mailers.smtp.username' => $username,
            'mail.mailers.smtp.password' => $password,
            'mail.mailers.smtp.scheme'   => $mailerScheme,
        ]);

        // Forzar una nueva instancia del transportador
        Mail::purge('smtp');

        return true;
    }

    /**
     * Obtiene la configuración SMTP actual (sin la contraseña por seguridad).
     */
    public static function obtenerConfiguracion(): array
    {
        $keys = ['smtp_host', 'smtp_port', 'smtp_username', 'smtp_password', 'smtp_encryption', 'smtp_activo'];
        $result = [];
        foreach ($keys as $k) {
            $result[$k] = DB::table('configuracion')->where('clave', $k)->value('valor') ?? '';
        }
        // Enmascarar la contraseña
        $result['smtp_password'] = !empty($result['smtp_password']) ? str_repeat('*', 8) : '';
        return $result;
    }

    /**
     * Guarda la configuración SMTP en la tabla `configuracion`.
     */
    public static function guardarConfiguracion(array $data): void
    {
        $allowed = ['smtp_host', 'smtp_port', 'smtp_username', 'smtp_password', 'smtp_encryption', 'smtp_activo'];
        foreach ($data as $clave => $valor) {
            if (in_array($clave, $allowed)) {
                DB::table('configuracion')->updateOrInsert(
                    ['clave' => $clave],
                    ['valor' => (string) $valor, 'updated_at' => now()]
                );
            }
        }
    }

    /**
     * Prueba la conexión SMTP con los datos configurados.
     * Retorna ['success' => bool, 'message' => string].
     */
    public static function probarConexion(): array
    {
        $host     = DB::table('configuracion')->where('clave', 'smtp_host')->value('valor') ?? '';
        $port     = DB::table('configuracion')->where('clave', 'smtp_port')->value('valor') ?? '587';
        $username = DB::table('configuracion')->where('clave', 'smtp_username')->value('valor') ?? '';
        $password = DB::table('configuracion')->where('clave', 'smtp_password')->value('valor') ?? '';
        $scheme   = DB::table('configuracion')->where('clave', 'smtp_encryption')->value('valor') ?? 'tls';

        if (empty($host)) {
            return ['success' => false, 'message' => 'El host SMTP no está configurado.'];
        }

        $errno = 0;
        $errstr = '';
        $timeout = 10;

        $remoteAddress = $scheme === 'ssl' ? "ssl://{$host}:{$port}" : "{$host}:{$port}";

        $fp = @stream_socket_client(
            $remoteAddress,
            $errno,
            $errstr,
            $timeout,
            STREAM_CLIENT_CONNECT,
            stream_context_create([
                'ssl' => [
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                ],
            ])
        );

        if (!$fp) {
            return ['success' => false, 'message' => "No se pudo conectar a {$host}:{$port}. Error: {$errstr} ({$errno})"];
        }

        // Intentar TLS upgrade si es necesario
        if ($scheme === 'tls' && !stream_socket_enable_crypto($fp, true, STREAM_CRYPTO_METHOD_TLSv1_2_CLIENT | STREAM_CRYPTO_METHOD_TLSv1_3_CLIENT)) {
            fclose($fp);
            return ['success' => false, 'message' => "No se pudo establecer conexión TLS con {$host}:{$port}."];
        }

        // Si hay credenciales, intentar autenticar con EHLO/MAIL FROM
        if (!empty($username) && !empty($password)) {
            $banner = fgets($fp, 512);
            fputs($fp, "EHLO localhost\r\n");
            stream_get_contents($fp);

            // AUTH LOGIN
            fputs($fp, "AUTH LOGIN\r\n");
            $resp = fgets($fp, 512);

            fputs($fp, base64_encode($username) . "\r\n");
            $resp = fgets($fp, 512);

            fputs($fp, base64_encode($password) . "\r\n");
            $resp = fgets($fp, 512);

            if (strpos($resp, '235') === false) {
                fclose($fp);
                return ['success' => false, 'message' => "Autenticación SMTP fallida. Verifique usuario y contraseña. Respuesta: " . trim($resp)];
            }
        }

        fputs($fp, "QUIT\r\n");
        fclose($fp);

        return ['success' => true, 'message' => "Conexión SMTP exitosa a {$host}:{$port}"];
    }
}
