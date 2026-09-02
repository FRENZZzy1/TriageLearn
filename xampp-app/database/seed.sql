USE triagelearn;

-- Technical smoke-test content only. Replace with project-owner-approved/clinically validated educational content before student use.
INSERT INTO users (full_name,email,password_hash,role) VALUES
('Demo Student','student@triagelearn.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llCw9LqfQx2J1LhW7h0yG', 'STUDENT');
SET @student_id = LAST_INSERT_ID();
INSERT INTO student_progress (student_id,current_tier) VALUES (@student_id,1);

INSERT INTO scenarios (title,tier,esi_level,description,max_xp,time_limit,deterioration_stage_1_seconds,deterioration_stage_2_seconds,correct_routing,is_demo)
VALUES ('Week 1 Technical Demo Scenario',1,3,'Technical smoke-test scenario. Replace with validated ESI content.',50,300,180,240,'Urgent ED Assessment Queue',1);
SET @scenario_id = LAST_INSERT_ID();
INSERT INTO patients (scenario_id,name,age,sex,visit_type,chief_complaint,clinical_history,visible_condition,english_dialogue,filipino_dialogue)
VALUES (@scenario_id,'Demo Patient',30,'Not specified','Technical Demo','Demo chief complaint — replace with validated content.','Demo clinical history — replace with validated content.','Demo visible condition — replace with validated content.','Demo dialogue — replace with validated content.','Demo dialogue — replace with validated content.');
INSERT INTO vital_signs (scenario_id,type,correct_value,unit,interpretation_question,correct_interpretation) VALUES (@scenario_id,'DEMO_VITAL','REPLACE','REPLACE','Demo interpretation prompt — replace with validated content.','REPLACE');
INSERT INTO interview_questions (scenario_id,question,response,is_priority,display_order) VALUES
(@scenario_id,'Demo priority question — replace with validated content.','Demo response.',1,1),
(@scenario_id,'Demo question — replace with validated content.','Demo response.',0,2),
(@scenario_id,'Demo question — replace with validated content.','Demo response.',0,3),
(@scenario_id,'Demo question — replace with validated content.','Demo response.',0,4);
INSERT INTO assessment_findings (scenario_id,finding,is_correct) VALUES (@scenario_id,'Demo correct finding — replace with validated content.',1),(@scenario_id,'Demo distractor — replace with validated content.',0);
INSERT INTO triage_decisions (scenario_id,correct_esi,undertriage_feedback,overtriage_feedback,correct_feedback) VALUES (@scenario_id,3,'Demo undertriage feedback — replace with validated rationale.','Demo overtriage feedback — replace with validated rationale.','Demo correct ESI feedback — replace with validated rationale.');
INSERT INTO routing_options (scenario_id,option_name,is_correct,is_critical_failure,feedback) VALUES
(@scenario_id,'Resuscitation Area',0,0,'Demo routing feedback.'),(@scenario_id,'Emergency Treatment Area',0,0,'Demo routing feedback.'),(@scenario_id,'Urgent ED Assessment Queue',1,0,'Demo correct routing feedback.'),(@scenario_id,'Minor Procedure Area',0,0,'Demo routing feedback.'),(@scenario_id,'Routine Consult / OPD',0,1,'Demo critical-failure routing feedback.');
