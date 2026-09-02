-- Technical smoke-test content only.
-- This row is explicitly marked is_demo=true and MUST be replaced by approved/validated educational content before student use.

INSERT INTO scenarios (
  id, title, tier, esi_level, description, max_xp, time_limit,
  deterioration_stage_1_seconds, deterioration_stage_2_seconds, correct_routing, is_demo
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Week 1 Technical Demo Scenario',
  1,
  3,
  'Technical smoke-test scenario for validating the patient-arrival flow. Replace this content with project-owner-approved ESI content.',
  50,
  300,
  180,
  240,
  'Urgent ED Assessment Queue',
  TRUE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO patients (
  id, scenario_id, name, age, sex, visit_type, chief_complaint, clinical_history,
  visible_condition, english_dialogue, filipino_dialogue
) VALUES (
  '00000000-0000-0000-0000-000000000011',
  '00000000-0000-0000-0000-000000000001',
  'Demo Patient',
  30,
  'Not specified',
  'Technical Demo',
  'Demo chief complaint — replace with validated content.',
  'Demo clinical history — replace with validated content.',
  'Demo visible condition — replace with validated content.',
  'Demo dialogue — replace with validated content.',
  'Demo dialogue — replace with validated content.'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO vital_signs (scenario_id, type, correct_value, unit, interpretation_question, correct_interpretation)
VALUES ('00000000-0000-0000-0000-000000000001', 'DEMO_VITAL', 'REPLACE', 'REPLACE', 'Demo interpretation prompt — replace with validated content.', 'REPLACE')
ON CONFLICT DO NOTHING;

INSERT INTO interview_questions (scenario_id, question, response, is_priority, display_order)
VALUES
('00000000-0000-0000-0000-000000000001', 'Demo priority question — replace with validated content.', 'Demo response.', TRUE, 1),
('00000000-0000-0000-0000-000000000001', 'Demo question — replace with validated content.', 'Demo response.', FALSE, 2),
('00000000-0000-0000-0000-000000000001', 'Demo question — replace with validated content.', 'Demo response.', FALSE, 3),
('00000000-0000-0000-0000-000000000001', 'Demo question — replace with validated content.', 'Demo response.', FALSE, 4);

INSERT INTO assessment_findings (scenario_id, finding, is_correct)
VALUES
('00000000-0000-0000-0000-000000000001', 'Demo correct finding — replace with validated content.', TRUE),
('00000000-0000-0000-0000-000000000001', 'Demo distractor — replace with validated content.', FALSE);

INSERT INTO triage_decisions (scenario_id, correct_esi, undertriage_feedback, overtriage_feedback, correct_feedback)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  3,
  'Demo undertriage feedback — replace with validated educational rationale.',
  'Demo overtriage feedback — replace with validated educational rationale.',
  'Demo correct ESI feedback — replace with validated educational rationale.'
) ON CONFLICT (scenario_id) DO NOTHING;

INSERT INTO routing_options (scenario_id, option_name, is_correct, is_critical_failure, feedback)
VALUES
('00000000-0000-0000-0000-000000000001', 'Resuscitation Area', FALSE, FALSE, 'Demo routing feedback.'),
('00000000-0000-0000-0000-000000000001', 'Emergency Treatment Area', FALSE, FALSE, 'Demo routing feedback.'),
('00000000-0000-0000-0000-000000000001', 'Urgent ED Assessment Queue', TRUE, FALSE, 'Demo correct routing feedback.'),
('00000000-0000-0000-0000-000000000001', 'Minor Procedure Area', FALSE, FALSE, 'Demo routing feedback.'),
('00000000-0000-0000-0000-000000000001', 'Routine Consult / OPD', FALSE, TRUE, 'Demo critical-failure routing feedback.');
