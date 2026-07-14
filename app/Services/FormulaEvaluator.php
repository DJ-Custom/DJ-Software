<?php

namespace App\Services;

use App\Models\PlanillaVariable;

class FormulaEvaluator
{
    private FormulaParser $parser;

    public function __construct(FormulaParser $parser)
    {
        $this->parser = $parser;
    }

    public function evaluate(string $formula, array $variables): float
    {
        $tokens = $this->parser->tokenize($formula);
        $resolved = $this->resolveVariables($tokens, $variables);
        $result = $this->computeExpression($resolved);

        if (!is_numeric($result)) {
            throw new \RuntimeException('Error al evaluar la fórmula: resultado no numérico.');
        }

        return round((float) $result, 2);
    }

    public function simulate(string $formula, array $variables): array
    {
        $tokens = $this->parser->tokenize($formula);
        $steps = [];
        $resolvedTokens = [];

        // Paso 1: Mostrar tokens originales
        $steps[] = [
            'step' => 1,
            'description' => 'Fórmula original',
            'formula' => $formula,
            'tokens' => array_map(fn($t) => $t['value'], $tokens),
        ];

        // Paso 2: Resolver variables
        foreach ($tokens as $token) {
            if ($token['type'] === 'variable') {
                $valor = $variables[$token['value']] ?? 0;
                $resolvedTokens[] = ['type' => 'number', 'value' => $valor];
                $steps[] = [
                    'step' => count($steps) + 1,
                    'description' => "Reemplazar {$token['value']} = {$valor}",
                    'operation' => "{$token['value']} → {$valor}",
                ];
            } else {
                $resolvedTokens[] = $token;
            }
        }

        // Paso 3: Evaluar expresión paso a paso
        $exprParts = array_map(fn($t) => $this->formatTokenValue($t), $resolvedTokens);
        $expression = implode(' ', $exprParts);

        $steps[] = [
            'step' => count($steps) + 1,
            'description' => 'Expresión a evaluar',
            'expression' => $expression,
        ];

        // Calcular resultado final
        $resultado = $this->computeExpression($resolvedTokens);

        $steps[] = [
            'step' => count($steps) + 1,
            'description' => 'Resultado final',
            'result' => round((float) $resultado, 2),
        ];

        // Clasificar ingresos y deducciones
        $totalIngresos = 0;
        $totalDeducciones = 0;

        foreach ($variables as $clave => $valor) {
            $var = PlanillaVariable::where('clave', $clave)->first();
            if ($var && is_numeric($valor)) {
                if ($var->tipo === 'ingreso') $totalIngresos += $valor;
                if ($var->tipo === 'deduccion') $totalDeducciones += $valor;
            }
        }

        return [
            'formula' => $formula,
            'variables_utilizadas' => collect($tokens)
                ->where('type', 'variable')
                ->map(function ($t) use ($variables) {
                    $varModel = PlanillaVariable::where('clave', $t['value'])->first();
                    return [
                        'clave' => $t['value'],
                        'nombre' => $varModel ? $varModel->nombre : $t['value'],
                        'valor' => $variables[$t['value']] ?? 0,
                    ];
                })
                ->values()
                ->toArray(),
            'pasos' => $steps,
            'total_ingresos' => round($totalIngresos, 2),
            'total_deducciones' => round($totalDeducciones, 2),
            'resultado' => round((float) $resultado, 2),
        ];
    }

    private function resolveVariables(array $tokens, array $variables): array
    {
        $resolved = [];
        foreach ($tokens as $token) {
            if ($token['type'] === 'variable') {
                $valor = $variables[$token['value']] ?? 0;
                $resolved[] = ['type' => 'number', 'value' => (float) $valor];
            } else {
                $resolved[] = $token;
            }
        }
        return $resolved;
    }

    private function computeExpression(array $tokens): float
    {
        // Convertir tokens a expresión matemática segura
        $expr = '';
        foreach ($tokens as $token) {
            if ($token['type'] === 'number') {
                $expr .= $token['value'];
            } elseif ($token['type'] === 'operator') {
                $expr .= ' ' . $token['value'] . ' ';
            }
        }

        $expr = trim($expr);

        if (empty($expr)) return 0;

        // Evaluar de forma segura sin eval()
        return $this->safeCalc($expr);
    }

    private function safeCalc(string $expr): float
    {
        // Eliminar espacios múltiples
        $expr = preg_replace('/\s+/', ' ', $expr);
        $expr = trim($expr);

        // Usar PHP Math como fallback seguro
        // Reemplazar operadores de resta con el unicode para evitar confusión con negativos
        $expr = str_replace(['-', '+'], [' − ', ' + '], $expr);
        $expr = str_replace(' × ', '*', $expr);
        $expr = str_replace(' ÷ ', '/', $expr);
        $expr = str_replace(' − ', '-', $expr);

        // Validar que solo contenga caracteres seguros
        if (!preg_match('/^[0-9\.\+\-\*\/\(\)\s]+$/', $expr)) {
            throw new \RuntimeException('Expresión contiene caracteres no permitidos.');
        }

        // Usar eval con sandbox mínimo (expresión aritmética pura ya validada)
        $result = @eval("return (float)({$expr});");

        if ($result === false) {
            throw new \RuntimeException('Error al calcular la expresión.');
        }

        return (float) $result;
    }

    private function formatTokenValue(array $token): string
    {
        if ($token['type'] === 'number') {
            return number_format($token['value'], 2, '.', '');
        }
        return (string) $token['value'];
    }

    public function applyDefaultFormula(array $variables): array
    {
        // Fórmula estándar por defecto
        $formula = 'salario_base + monto_horas_extra + bonificaciones + comisiones + incentivos - ccss - impuesto_renta - rebajos - embargos - otras_deducciones + otros_ingresos';

        // Auto-calcular monto_horas_extra si hay horas extra
        if (isset($variables['horas_extra']) && $variables['horas_extra'] > 0) {
            $salarioDiario = ($variables['salario_base'] ?? 0) / 30;
            $jornada = $variables['jornada_laboral'] ?? 8;
            $pagoHora = $salarioDiario / $jornada;
            $variables['monto_horas_extra'] = round($variables['horas_extra'] * $pagoHora * 1.5, 2);
        }

        // Auto-calcular CCSS si no viene definido
        if (!isset($variables['ccss']) && isset($variables['salario_base'])) {
            $variables['ccss'] = round($variables['salario_base'] * 0.1067, 2);
        }

        return [
            'formula' => $formula,
            'variables' => $variables,
            'resultado' => $this->evaluate($formula, $variables),
        ];
    }
}
