CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_role AS ENUM ('STUDENT', 'FACULTY');
CREATE TYPE assessment_type AS ENUM ('PRETEST', 'POSTTEST');
CREATE TYPE attempt_status AS ENUM ('IN_PROGRESS', 'COMPLETED', 'FAILED', 'CRITICAL_FAILURE');
CREATE TYPE xp_action AS ENUM ('INTERVIEW_CORRECT', 'INTERVIEW_INCORRECT', 'VITAL_CORRECT', 'VITAL_INCORRECT', 'ASSESSMENT_CORRECT', 'ASSESSMENT_INCORRECT', 'ESI_CORRECT', 'ESI_INCORRECT', 'ROUTING_CORRECT', 'ROUTING_INCORRECT', 'SCENARIO_COMPLETION', 'TIME_BONUS', 'PENALTY');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'STUDENT',
  nickname VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE student_progress (
  student_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_xp INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
  current_tier SMALLINT NOT NULL DEFAULT 1 CHECK (current_tier BETWEEN 1 AND 3),
  pretest_completed_at TIMESTAMPTZ,
  tutorial_completed_at TIMESTAMPTZ,
  posttest_completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE assessment_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  choices JSONB NOT NULL,
  correct_answer TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (jsonb_typeof(choices) = 'array')
);

CREATE TABLE assessment_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  assessment_type assessment_type NOT NULL,
  score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
  total_items INTEGER NOT NULL DEFAULT 15 CHECK (total_items > 0),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(student_id, assessment_type)
);

CREATE TABLE assessment_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES assessment_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES assessment_questions(id),
  selected_answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(attempt_id, question_id)
);

CREATE TABLE scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  tier SMALLINT NOT NULL CHECK (tier BETWEEN 1 AND 3),
  esi_level SMALLINT NOT NULL CHECK (esi_level BETWEEN 1 AND 5),
  description TEXT NOT NULL,
  max_xp INTEGER NOT NULL CHECK (max_xp >= 0),
  time_limit INTEGER NOT NULL CHECK (time_limit > 0),
  deterioration_stage_1_seconds INTEGER CHECK (deterioration_stage_1_seconds IS NULL OR deterioration_stage_1_seconds > 0),
  deterioration_stage_2_seconds INTEGER CHECK (deterioration_stage_2_seconds IS NULL OR deterioration_stage_2_seconds > 0),
  correct_routing VARCHAR(80) NOT NULL,
  is_demo BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL UNIQUE REFERENCES scenarios(id) ON DELETE CASCADE,
  name VARCHAR(120) NOT NULL,
  age SMALLINT NOT NULL CHECK (age >= 0),
  sex VARCHAR(30) NOT NULL,
  visit_type VARCHAR(80) NOT NULL,
  chief_complaint TEXT NOT NULL,
  clinical_history TEXT NOT NULL,
  visible_condition TEXT NOT NULL,
  english_dialogue TEXT NOT NULL,
  filipino_dialogue TEXT NOT NULL
);

CREATE TABLE vital_signs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  type VARCHAR(60) NOT NULL,
  correct_value VARCHAR(80) NOT NULL,
  unit VARCHAR(40) NOT NULL,
  interpretation_question TEXT NOT NULL,
  correct_interpretation TEXT NOT NULL,
  xp_correct INTEGER NOT NULL DEFAULT 10,
  xp_incorrect INTEGER NOT NULL DEFAULT -5
);

CREATE TABLE interview_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  response TEXT NOT NULL,
  is_priority BOOLEAN NOT NULL DEFAULT FALSE,
  xp_reward INTEGER NOT NULL DEFAULT 10,
  xp_penalty INTEGER NOT NULL DEFAULT -5,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE assessment_findings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  finding TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  xp_reward INTEGER NOT NULL DEFAULT 10,
  xp_penalty INTEGER NOT NULL DEFAULT -5
);

CREATE TABLE triage_decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL UNIQUE REFERENCES scenarios(id) ON DELETE CASCADE,
  correct_esi SMALLINT NOT NULL CHECK (correct_esi BETWEEN 1 AND 5),
  undertriage_feedback TEXT NOT NULL,
  overtriage_feedback TEXT NOT NULL,
  correct_feedback TEXT NOT NULL,
  xp_penalty INTEGER NOT NULL DEFAULT -30
);

CREATE TABLE routing_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  option_name VARCHAR(100) NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  is_critical_failure BOOLEAN NOT NULL DEFAULT FALSE,
  feedback TEXT NOT NULL,
  xp_reward INTEGER NOT NULL DEFAULT 10,
  xp_penalty INTEGER NOT NULL DEFAULT -20
);

CREATE TABLE scenario_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  scenario_id UUID NOT NULL REFERENCES scenarios(id),
  status attempt_status NOT NULL DEFAULT 'IN_PROGRESS',
  scenario_start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  scenario_end_time TIMESTAMPTZ,
  total_duration_seconds INTEGER,
  xp_earned INTEGER NOT NULL DEFAULT 0,
  accuracy NUMERIC(5,2) NOT NULL DEFAULT 0,
  percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
  performance_rating VARCHAR(30),
  correct_esi SMALLINT,
  selected_route VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE interview_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES scenario_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES interview_questions(id),
  is_correct BOOLEAN NOT NULL,
  xp_delta INTEGER NOT NULL,
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE vital_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES scenario_attempts(id) ON DELETE CASCADE,
  vital_sign_id UUID NOT NULL REFERENCES vital_signs(id),
  observed_value VARCHAR(80) NOT NULL,
  interpretation TEXT,
  is_correct BOOLEAN NOT NULL,
  xp_delta INTEGER NOT NULL,
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE assessment_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES scenario_attempts(id) ON DELETE CASCADE,
  finding_id UUID NOT NULL REFERENCES assessment_findings(id),
  is_correct BOOLEAN NOT NULL,
  xp_delta INTEGER NOT NULL,
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE triage_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES scenario_attempts(id) ON DELETE CASCADE,
  selected_esi SMALLINT NOT NULL CHECK (selected_esi BETWEEN 1 AND 5),
  is_correct BOOLEAN NOT NULL,
  undertriage BOOLEAN NOT NULL DEFAULT FALSE,
  overtriage BOOLEAN NOT NULL DEFAULT FALSE,
  critical_failure BOOLEAN NOT NULL DEFAULT FALSE,
  xp_delta INTEGER NOT NULL,
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE routing_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES scenario_attempts(id) ON DELETE CASCADE,
  routing_option_id UUID NOT NULL REFERENCES routing_options(id),
  is_correct BOOLEAN NOT NULL,
  critical_failure BOOLEAN NOT NULL DEFAULT FALSE,
  xp_delta INTEGER NOT NULL,
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE xp_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  attempt_id UUID REFERENCES scenario_attempts(id) ON DELETE SET NULL,
  action xp_action NOT NULL,
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_scenarios_tier ON scenarios(tier);
CREATE INDEX idx_attempts_student ON scenario_attempts(student_id);
CREATE INDEX idx_attempts_scenario ON scenario_attempts(scenario_id);
CREATE INDEX idx_xp_student ON xp_ledger(student_id, created_at DESC);
CREATE INDEX idx_assessment_answers_attempt ON assessment_answers(attempt_id);

CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER progress_updated_at BEFORE UPDATE ON student_progress FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
