CREATE DATABASE IF NOT EXISTS triagelearn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE triagelearn;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('STUDENT','FACULTY') NOT NULL DEFAULT 'STUDENT',
  nickname VARCHAR(80) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE student_progress (
  student_id INT UNSIGNED PRIMARY KEY,
  total_xp INT NOT NULL DEFAULT 0,
  current_tier TINYINT UNSIGNED NOT NULL DEFAULT 1,
  pretest_completed_at DATETIME NULL,
  tutorial_completed_at DATETIME NULL,
  posttest_completed_at DATETIME NULL,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  CHECK (current_tier BETWEEN 1 AND 3)
) ENGINE=InnoDB;

CREATE TABLE scenarios (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  tier TINYINT UNSIGNED NOT NULL,
  esi_level TINYINT UNSIGNED NOT NULL,
  description TEXT NOT NULL,
  max_xp INT NOT NULL DEFAULT 0,
  time_limit INT NOT NULL DEFAULT 300,
  deterioration_stage_1_seconds INT NULL,
  deterioration_stage_2_seconds INT NULL,
  correct_routing VARCHAR(100) NOT NULL,
  is_demo TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (tier BETWEEN 1 AND 3),
  CHECK (esi_level BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE patients (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  age TINYINT UNSIGNED NOT NULL,
  sex VARCHAR(30) NOT NULL,
  visit_type VARCHAR(80) NOT NULL,
  chief_complaint TEXT NOT NULL,
  clinical_history TEXT NOT NULL,
  visible_condition TEXT NOT NULL,
  english_dialogue TEXT NOT NULL,
  filipino_dialogue TEXT NOT NULL,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE vital_signs (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL,
  type VARCHAR(60) NOT NULL,
  correct_value VARCHAR(80) NOT NULL,
  unit VARCHAR(40) NOT NULL,
  interpretation_question TEXT NOT NULL,
  correct_interpretation TEXT NOT NULL,
  xp_correct INT NOT NULL DEFAULT 10,
  xp_incorrect INT NOT NULL DEFAULT -5,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE interview_questions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL,
  question TEXT NOT NULL,
  response TEXT NOT NULL,
  is_priority TINYINT(1) NOT NULL DEFAULT 0,
  xp_reward INT NOT NULL DEFAULT 10,
  xp_penalty INT NOT NULL DEFAULT -5,
  display_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE assessment_findings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL,
  finding TEXT NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  xp_reward INT NOT NULL DEFAULT 10,
  xp_penalty INT NOT NULL DEFAULT -5,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE triage_decisions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL UNIQUE,
  correct_esi TINYINT UNSIGNED NOT NULL,
  undertriage_feedback TEXT NOT NULL,
  overtriage_feedback TEXT NOT NULL,
  correct_feedback TEXT NOT NULL,
  xp_penalty INT NOT NULL DEFAULT -30,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE,
  CHECK (correct_esi BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE routing_options (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  scenario_id INT UNSIGNED NOT NULL,
  option_name VARCHAR(100) NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  is_critical_failure TINYINT(1) NOT NULL DEFAULT 0,
  feedback TEXT NOT NULL,
  xp_reward INT NOT NULL DEFAULT 10,
  xp_penalty INT NOT NULL DEFAULT -20,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE scenario_attempts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id INT UNSIGNED NOT NULL,
  scenario_id INT UNSIGNED NOT NULL,
  status ENUM('IN_PROGRESS','COMPLETED','FAILED','CRITICAL_FAILURE') NOT NULL DEFAULT 'IN_PROGRESS',
  scenario_start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  scenario_end_time DATETIME NULL,
  total_duration_seconds INT NULL,
  xp_earned INT NOT NULL DEFAULT 0,
  accuracy DECIMAL(5,2) NOT NULL DEFAULT 0,
  percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  performance_rating VARCHAR(30) NULL,
  correct_esi TINYINT UNSIGNED NULL,
  selected_route VARCHAR(100) NULL,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scenario_id) REFERENCES scenarios(id) ON DELETE RESTRICT,
  INDEX idx_attempt_student (student_id),
  INDEX idx_attempt_scenario (scenario_id)
) ENGINE=InnoDB;

CREATE TABLE xp_ledger (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id INT UNSIGNED NOT NULL,
  attempt_id BIGINT UNSIGNED NULL,
  action VARCHAR(40) NOT NULL,
  amount INT NOT NULL,
  reason VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (attempt_id) REFERENCES scenario_attempts(id) ON DELETE SET NULL,
  INDEX idx_xp_student (student_id, created_at)
) ENGINE=InnoDB;
