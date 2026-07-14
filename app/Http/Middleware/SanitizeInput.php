<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SanitizeInput
{
    protected array $except = ['password', 'password_confirmation', 'current_password'];

    public function handle(Request $request, Closure $next)
    {
        $input = $request->all();
        $request->merge($this->clean($input));
        return $next($request);
    }

    private function clean(array $data): array
    {
        return collect($data)->map(function ($value, $key) {
            if (in_array($key, $this->except)) return $value;
            if (is_array($value)) return $this->clean($value);
            if (is_string($value)) {
                $value = strip_tags($value, '<b><i><u><strong><em><br><p><ul><ol><li><a><h1><h2><h3><h4><h5><h6><img><table><tr><td><th><thead><tbody><span><div>');
                $value = preg_replace('/on\w+\s*=\s*["\'][^"\']*["\']/i', '', $value);
                $value = preg_replace('/javascript\s*:/i', '', $value);
                $value = preg_replace('/<script\b[^>]*>(.*?)<\/script>/is', '', $value);
            }
            return $value;
        })->all();
    }
}
