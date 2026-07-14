<?php

namespace App\Services;

use App\Models\PlanillaVariable;
use Illuminate\Support\Facades\DB;

class FormulaParser
{
    private const OPERATORS = ['+', '-', '*', '/', '(', ')'];

    private const BLOCKED_PATTERNS = [
        '/\beval\b/i', '/\bexec\b/i', '/\bsystem\b/i', '/\bshell\b/i',
        '/\bpassthru\b/i', '/\bproc_open\b/i', '/\bpopen\b/i',
        '/\bcurl\b/i', '/\bfile_get_contents\b/i', '/\bfile_put_contents\b/i',
        '/\bunlink\b/i', '/\brmdir\b/i', '/\bmkdir\b/i', '/\bchmod\b/i',
        '/\bchown\b/i', '/\bphpinfo\b/i', '/\binclude\b/i', '/\brequire\b/i',
        '/\binclude_once\b/i', '/\brequire_once\b/i', '/\bbase64\b/i',
        '/\bstr_rot13\b/i', '/\bhex2bin\b/i', '/\bassert\b/i',
        '/\<\?php/i', '/\<script/i', '/\bfunction\s*\(/i',
        '/\$\{/', '/\bvar_dump\b/i', '/\bprint_r\b/i',
    ];

    public function getAvailableVariables(): array
    {
        return PlanillaVariable::activas()
            ->orderBy('tipo')
            ->orderBy('nombre')
            ->get()
            ->toArray();
    }

    public function tokenize(string $formula): array
    {
        $formula = trim($formula);
        if (empty($formula)) {
            throw new \InvalidArgumentException('La fórmula no puede estar vacía.');
        }

        $tokens = [];
        $i = 0;
        $len = strlen($formula);

        while ($i < $len) {
            if ($formula[$i] === ' ') {
                $i++;
                continue;
            }

            // Operadores
            if (in_array($formula[$i], self::OPERATORS)) {
                $tokens[] = ['type' => 'operator', 'value' => $formula[$i]];
                $i++;
                continue;
            }

            // Números (incluye decimales)
            if (is_numeric($formula[$i]) || ($formula[$i] === '.' && $i + 1 < $len && is_numeric($formula[$i + 1]))) {
                $num = '';
                while ($i < $len && (is_numeric($formula[$i]) || $formula[$i] === '.')) {
                    $num .= $formula[$i];
                    $i++;
                }
                $tokens[] = ['type' => 'number', 'value' => (float) $num];
                continue;
            }

            // Variables (letras, números, guiones bajos)
            if (preg_match('/[a-zA-Z_]/', $formula[$i])) {
                $var = '';
                while ($i < $len && preg_match('/[a-zA-Z0-9_]/', $formula[$i])) {
                    $var .= $formula[$i];
                    $i++;
                }
                $tokens[] = ['type' => 'variable', 'value' => $var];
                continue;
            }

            throw new \InvalidArgumentException("Carácter inválido en la fórmula: '{$formula[$i]}' en posición {$i}.");
        }

        return $tokens;
    }

    public function validate(string $formula): array
    {
        $errors = [];

        if (empty(trim($formula))) {
            return ['La fórmula no puede estar vacía.'];
        }

        // Verificar código malicioso
        foreach (self::BLOCKED_PATTERNS as $pattern) {
            if (preg_match($pattern, $formula)) {
                $errors[] = 'La fórmula contiene código no permitido.';
                return $errors;
            }
        }

        // Tokenizar
        try {
            $tokens = $this->tokenize($formula);
        } catch (\InvalidArgumentException $e) {
            return [$e->getMessage()];
        }

        // Validar paréntesis balanceados
        $parenCount = 0;
        foreach ($tokens as $token) {
            if ($token['value'] === '(') $parenCount++;
            if ($token['value'] === ')') $parenCount--;
            if ($parenCount < 0) {
                $errors[] = 'Paréntesis de cierre sin apertura.';
                break;
            }
        }
        if ($parenCount !== 0) {
            $errors[] = 'Paréntesis desbalanceados.';
        }

        // Validar que no empiece o termine con operador (excepto -)
        if (!empty($tokens)) {
            $first = $tokens[0];
            if ($first['type'] === 'operator' && !in_array($first['value'], ['-', '('])) {
                $errors[] = 'La fórmula no puede empezar con el operador "' . $first['value'] . '".';
            }
            $last = end($tokens);
            if ($last['type'] === 'operator' && !in_array($last['value'], [')'])) {
                $errors[] = 'La fórmula no puede terminar con el operador "' . $last['value'] . '".';
            }
        }

        // Validar operadores consecutivos
        for ($i = 1; $i < count($tokens); $i++) {
            $prev = $tokens[$i - 1];
            $curr = $tokens[$i];
            if ($prev['type'] === 'operator' && $curr['type'] === 'operator'
                && !in_array($curr['value'], ['-', '('])
                && !in_array($prev['value'], [')'])) {
                $errors[] = 'Operadores consecutivos inválidos.';
                break;
            }
        }

        // Validar variables
        $validVariables = $this->getAvailableVariables()->pluck('clave')->toArray();
        foreach ($tokens as $token) {
            if ($token['type'] === 'variable' && !in_array($token['value'], $validVariables)) {
                $errors[] = "Variable no reconocida: '{$token['value']}'.";
            }
        }

        // Validar que haya al menos una operación o variable
        $hasOperation = collect($tokens)->contains('type', 'operator');
        $hasVariable = collect($tokens)->contains('type', 'variable');
        if (!$hasOperation && !$hasVariable) {
            $errors[] = 'La fórmula debe contener al menos una operación o variable.';
        }

        return $errors;
    }

    public function sanitize(string $formula): string
    {
        $formula = strip_tags($formula);
        $formula = preg_replace('/\s+/', ' ', $formula);
        return trim($formula);
    }

    public function formatFormula(string $formula): array
    {
        $tokens = $this->tokenize($formula);
        $parts = [];

        foreach ($tokens as $token) {
            $parts[] = [
                'type' => $token['type'],
                'value' => $token['value'],
                'color' => $this->getTokenColor($token),
            ];
        }

        return $parts;
    }

    private function getTokenColor(array $token): string
    {
        return match ($token['type']) {
            'number' => '#3b82f6',
            'variable' => $this->getVariableColor($token['value']),
            'operator' => in_array($token['value'], ['+', '-']) ? '#ef4444' : '#8b5cf6',
            default => '#6b7280',
        };
    }

    private function getVariableColor(string $var): string
    {
        $variable = PlanillaVariable::where('clave', $var)->first();
        if (!$variable) return '#6b7280';

        return match ($variable->tipo) {
            'ingreso' => '#22c55e',
            'deduccion' => '#ef4444',
            'operacion' => '#3b82f6',
            default => '#6b7280',
        };
    }
}
