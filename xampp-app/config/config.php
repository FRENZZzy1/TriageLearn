<?php
declare(strict_types=1);

session_start();

const APP_NAME = 'TriageLearn';
const BASE_URL = '/TriageLearn/xampp-app/public';

$dbHost = getenv('TRIAGE_DB_HOST') ?: '127.0.0.1';
$dbName = getenv('TRIAGE_DB_NAME') ?: 'triagelearn';
$dbUser = getenv('TRIAGE_DB_USER') ?: 'root';
$dbPass = getenv('TRIAGE_DB_PASS') ?: '';
$dbPort = getenv('TRIAGE_DB_PORT') ?: '3306';

try {
    $pdo = new PDO("mysql:host={$dbHost};port={$dbPort};dbname={$dbName};charset=utf8mb4", $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    exit('Database connection failed. Check XAMPP/MySQL and config values.');
}
