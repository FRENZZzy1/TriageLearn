import { pool } from '../db/pool.js';

export async function listScenarios(req, res) {
  const result = await pool.query(
    `SELECT id, title, tier, description, max_xp, time_limit
     FROM scenarios
     WHERE tier <= COALESCE((SELECT current_tier FROM student_progress WHERE student_id = $1), 1)
        OR $2 = 'FACULTY'
     ORDER BY tier ASC, id ASC`,
    [req.auth.sub, req.auth.role],
  );
  return res.json({ scenarios: result.rows });
}

export async function getScenario(req, res) {
  const result = await pool.query(
    `SELECT s.id, s.title, s.tier, s.description, s.max_xp, s.time_limit,
            p.id AS patient_id, p.name, p.age, p.sex, p.visit_type,
            p.chief_complaint, p.clinical_history, p.visible_condition,
            p.english_dialogue, p.filipino_dialogue
     FROM scenarios s
     JOIN patients p ON p.scenario_id = s.id
     WHERE s.id = $1`,
    [req.params.id],
  );
  if (!result.rows[0]) return res.status(404).json({ message: 'Scenario not found.' });
  const row = result.rows[0];
  return res.json({
    scenario: {
      id: row.id,
      title: row.title,
      tier: row.tier,
      description: row.description,
      max_xp: row.max_xp,
      time_limit: row.time_limit,
      patient: {
        id: row.patient_id,
        name: row.name,
        age: row.age,
        sex: row.sex,
        visit_type: row.visit_type,
        chief_complaint: row.chief_complaint,
        clinical_history: row.clinical_history,
        visible_condition: row.visible_condition,
        english_dialogue: row.english_dialogue,
        filipino_dialogue: row.filipino_dialogue,
      },
    },
  });
}

export async function startScenario(req, res) {
  const scenario = await pool.query('SELECT id, tier FROM scenarios WHERE id = $1', [req.params.id]);
  if (!scenario.rows[0]) return res.status(404).json({ message: 'Scenario not found.' });
  if (scenario.rows[0].tier > 1) {
    const progress = await pool.query('SELECT current_tier FROM student_progress WHERE student_id = $1', [req.auth.sub]);
    if ((progress.rows[0]?.current_tier ?? 1) < scenario.rows[0].tier) {
      return res.status(403).json({ message: 'This tier is locked.' });
    }
  }
  const result = await pool.query(
    `INSERT INTO scenario_attempts (student_id, scenario_id)
     VALUES ($1, $2) RETURNING id, scenario_id, status, scenario_start_time`,
    [req.auth.sub, req.params.id],
  );
  return res.status(201).json({ attempt: result.rows[0] });
}
