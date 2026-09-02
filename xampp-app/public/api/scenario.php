<?php
declare(strict_types=1);
require_once __DIR__ . '/../../includes/auth.php';
require_login();
header('Content-Type: application/json; charset=utf-8');

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id) { http_response_code(400); echo json_encode(['message'=>'Invalid scenario id.']); exit; }
$stmt = $pdo->prepare('SELECT s.id,s.title,s.tier,s.description,s.max_xp,s.time_limit,p.name,p.age,p.sex,p.visit_type,p.chief_complaint,p.visible_condition,p.english_dialogue,p.filipino_dialogue FROM scenarios s JOIN patients p ON p.scenario_id=s.id WHERE s.id=? LIMIT 1');
$stmt->execute([$id]);
$row = $stmt->fetch();
if (!$row) { http_response_code(404); echo json_encode(['message'=>'Scenario not found.']); exit; }

echo json_encode(['scenario'=>[
  'id'=>(int)$row['id'],'title'=>$row['title'],'tier'=>(int)$row['tier'],'description'=>$row['description'],
  'max_xp'=>(int)$row['max_xp'],'time_limit'=>(int)$row['time_limit'],
  'patient'=>['name'=>$row['name'],'age'=>(int)$row['age'],'sex'=>$row['sex'],'visit_type'=>$row['visit_type'],'chief_complaint'=>$row['chief_complaint'],'visible_condition'=>$row['visible_condition'],'english_dialogue'=>$row['english_dialogue'],'filipino_dialogue'=>$row['filipino_dialogue']]
]]);
