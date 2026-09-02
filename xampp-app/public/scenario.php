<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
require_login();
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id) { http_response_code(400); exit('Invalid scenario.'); }
$stmt = $pdo->prepare('SELECT s.*, p.name, p.age, p.sex, p.visit_type, p.chief_complaint, p.visible_condition, p.english_dialogue, p.filipino_dialogue FROM scenarios s JOIN patients p ON p.scenario_id=s.id WHERE s.id=? LIMIT 1');
$stmt->execute([$id]);
$scenario = $stmt->fetch();
if (!$scenario) { http_response_code(404); exit('Scenario not found.'); }
if ($_SESSION['role'] === 'STUDENT') {
  $gate = $pdo->prepare('SELECT current_tier FROM student_progress WHERE student_id=?'); $gate->execute([$_SESSION['user_id']]);
  if ($scenario['tier'] > (int)($gate->fetchColumn() ?: 1)) { http_response_code(403); exit('This tier is locked.'); }
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (!verify_csrf($_POST['csrf_token'] ?? null)) { http_response_code(419); exit('Invalid request.'); }
  $insert = $pdo->prepare('INSERT INTO scenario_attempts (student_id, scenario_id) VALUES (?, ?)');
  $insert->execute([$_SESSION['user_id'], $id]);
  header('Location: ' . BASE_URL . '/scenario.php?id=' . $id . '&attempt=' . $pdo->lastInsertId()); exit;
}
$attemptId = filter_input(INPUT_GET, 'attempt', FILTER_VALIDATE_INT);
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?= e($scenario['title']) ?> | TriageLearn</title><link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/app.css"></head><body><header class="topbar"><a class="brand" href="<?= BASE_URL ?>/dashboard.php">TRIAGE<span>LEARN</span></a><span id="timer"></span></header><main class="shell"><section class="card"><p class="eyebrow">TIER <?= (int)$scenario['tier'] ?> · ESI PRACTICE</p><h1><?= e($scenario['title']) ?></h1><p class="muted"><?= e($scenario['description']) ?></p><div class="patient"><h2>Patient arrival</h2><p><strong><?= e($scenario['name']) ?></strong>, <?= (int)$scenario['age'] ?>, <?= e($scenario['sex']) ?></p><p><?= e($scenario['visit_type']) ?></p><p><strong>Chief complaint:</strong> <?= e($scenario['chief_complaint']) ?></p><p><?= e($scenario['visible_condition']) ?></p></div><?php if (!$attemptId): ?><form method="post"><input type="hidden" name="csrf_token" value="<?= e(csrf_token()) ?>"><button type="submit">Approach patient &amp; start</button></form><?php else: ?><div class="alert success">Attempt #<?= (int)$attemptId ?> started. The scenario engine can now attach interview, vital-sign, assessment, ESI, routing, scoring, and feedback actions to this attempt.</div><div class="feature-row"><a class="button" href="<?= BASE_URL ?>/dashboard.php">Pause / return to dashboard</a></div><?php endif; ?></section></main><?php if ($attemptId): ?><script>window.TRIAGE_TIMER=<?= (int)$scenario['time_limit'] ?>;const t=document.getElementById('timer');let left=window.TRIAGE_TIMER;const tick=()=>{t.textContent='Time: '+Math.floor(left/60)+':'+String(left%60).padStart(2,'0');if(left>0){left--;setTimeout(tick,1000)}};tick();</script><?php endif; ?></body></html>
