<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
require_login();

$stmt = $pdo->prepare('SELECT id, title, tier, description, max_xp, time_limit, is_demo FROM scenarios WHERE tier <= (SELECT current_tier FROM student_progress WHERE student_id = ?) OR ? = "FACULTY" ORDER BY tier, id');
$stmt->execute([$_SESSION['user_id'], $_SESSION['role']]);
$scenarios = $stmt->fetchAll();
$progressStmt = $pdo->prepare('SELECT total_xp, current_tier FROM student_progress WHERE student_id = ?');
$progressStmt->execute([$_SESSION['user_id']]);
$progress = $progressStmt->fetch() ?: ['total_xp' => 0, 'current_tier' => 1];
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Dashboard | TriageLearn</title><link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/app.css"></head><body><header class="topbar"><div class="brand">TRIAGE<span>LEARN</span></div><div><?= e($_SESSION['full_name']) ?> · <a href="<?= BASE_URL ?>/logout.php">Logout</a></div></header><main class="shell"><section class="hero"><div><p class="eyebrow">LEARNING DASHBOARD</p><h1>Welcome, <?= e($_SESSION['full_name']) ?></h1><p class="muted">Practice ESI triage through structured patient simulations.</p></div><div class="stats"><div class="stat"><span>Total XP</span><strong><?= (int)$progress['total_xp'] ?></strong></div><div class="stat"><span>Unlocked Tier</span><strong><?= (int)$progress['current_tier'] ?></strong></div></div></section><h2>Available scenarios</h2><div class="grid"><?php foreach ($scenarios as $s): ?><article class="card scenario-card"><span class="badge">Tier <?= (int)$s['tier'] ?></span><?php if ($s['is_demo']): ?><span class="badge warning">Demo</span><?php endif; ?><h3><?= e($s['title']) ?></h3><p class="muted"><?= e($s['description']) ?></p><div class="scenario-meta"><span><?= (int)$s['time_limit'] ?> sec</span><span><?= (int)$s['max_xp'] ?> XP</span></div><a class="button" href="<?= BASE_URL ?>/scenario.php?id=<?= (int)$s['id'] ?>">Open scenario</a></article><?php endforeach; ?></div></main></body></html>
