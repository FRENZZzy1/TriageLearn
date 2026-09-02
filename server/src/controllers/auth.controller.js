import { z } from 'zod';
import { pool } from '../db/pool.js';
import { comparePassword, hashPassword } from '../utils/password.js';
import { signAccessToken } from '../utils/jwt.js';

const credentials = z.object({
  full_name: z.string().trim().min(2).max(150),
  email: z.string().trim().email().max(255),
  password: z.string().min(8).max(128),
});

const loginSchema = z.object({
  email: z.string().trim().email().max(255),
  password: z.string().min(1).max(128),
});

const publicUser = (row) => ({
  id: row.id,
  full_name: row.full_name,
  email: row.email,
  role: row.role,
  nickname: row.nickname,
  created_at: row.created_at,
});

const setAuthCookie = (res, token) => {
  res.cookie('access_token', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 8 * 60 * 60 * 1000,
    path: '/',
  });
};

export async function register(req, res) {
  const data = credentials.parse(req.body);
  const email = data.email.toLowerCase();
  const passwordHash = await hashPassword(data.password);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      `INSERT INTO users (full_name, email, password_hash, role)
       VALUES ($1, $2, $3, 'STUDENT')
       RETURNING id, full_name, email, role, nickname, created_at`,
      [data.full_name, email, passwordHash],
    );
    await client.query('INSERT INTO student_progress (student_id) VALUES ($1)', [result.rows[0].id]);
    await client.query('COMMIT');

    const user = result.rows[0];
    setAuthCookie(res, signAccessToken(user));
    return res.status(201).json({ user: publicUser(user) });
  } catch (error) {
    await client.query('ROLLBACK');
    if (error.code === '23505') return res.status(409).json({ message: 'An account with that email already exists.' });
    throw error;
  } finally {
    client.release();
  }
}

export async function login(req, res) {
  const data = loginSchema.parse(req.body);
  const result = await pool.query(
    `SELECT id, full_name, email, password_hash, role, nickname, created_at
     FROM users WHERE email = $1`,
    [data.email.toLowerCase()],
  );
  const user = result.rows[0];
  if (!user || !(await comparePassword(data.password, user.password_hash))) {
    return res.status(401).json({ message: 'Invalid email or password.' });
  }

  setAuthCookie(res, signAccessToken(user));
  return res.json({ user: publicUser(user) });
}

export function logout(req, res) {
  res.clearCookie('access_token', { httpOnly: true, sameSite: 'lax', path: '/' });
  return res.status(204).send();
}

export async function me(req, res) {
  const result = await pool.query(
    `SELECT u.id, u.full_name, u.email, u.role, u.nickname, u.created_at,
            p.total_xp, p.current_tier, p.pretest_completed_at,
            p.tutorial_completed_at, p.posttest_completed_at
     FROM users u
     LEFT JOIN student_progress p ON p.student_id = u.id
     WHERE u.id = $1`,
    [req.auth.sub],
  );
  if (!result.rows[0]) return res.status(401).json({ message: 'User account not found.' });
  const row = result.rows[0];
  return res.json({
    user: publicUser(row),
    progress: row.role === 'STUDENT' ? {
      total_xp: row.total_xp,
      current_tier: row.current_tier,
      pretest_completed_at: row.pretest_completed_at,
      tutorial_completed_at: row.tutorial_completed_at,
      posttest_completed_at: row.posttest_completed_at,
    } : null,
  });
}
