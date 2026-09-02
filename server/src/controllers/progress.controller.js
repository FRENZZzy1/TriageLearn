import { pool } from '../db/pool.js';

export async function getProgress(req, res) {
  const progress = await pool.query(
    `SELECT total_xp, current_tier, pretest_completed_at, tutorial_completed_at, posttest_completed_at
     FROM student_progress WHERE student_id = $1`,
    [req.auth.sub],
  );
  const recent = await pool.query(
    `SELECT a.id, a.scenario_id, s.title, a.status, a.xp_earned, a.accuracy,
            a.percentage, a.performance_rating, a.total_duration_seconds, a.created_at
     FROM scenario_attempts a
     JOIN scenarios s ON s.id = a.scenario_id
     WHERE a.student_id = $1
     ORDER BY a.created_at DESC LIMIT 5`,
    [req.auth.sub],
  );
  return res.json({ progress: progress.rows[0] ?? null, recent_results: recent.rows });
}
