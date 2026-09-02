import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';

export const signAccessToken = (user) => jwt.sign(
  { sub: user.id, role: user.role },
  env.JWT_SECRET,
  { expiresIn: '8h' },
);

export const verifyAccessToken = (token) => jwt.verify(token, env.JWT_SECRET);
