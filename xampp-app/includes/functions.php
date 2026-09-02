<?php
declare(strict_types=1);

function e(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8'); }

function csrf_token(): string {
    if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf_token'];
}

function verify_csrf(?string $token): bool {
    return is_string($token) && hash_equals($_SESSION['csrf_token'] ?? '', $token);
}

function performance_rating(float $percentage, bool $criticalFailure = false): string {
    if ($criticalFailure) return 'Critical Failure';
    if ($percentage >= 85) return 'Excellent';
    if ($percentage >= 70) return 'Pass';
    return 'Needs Improvement';
}
