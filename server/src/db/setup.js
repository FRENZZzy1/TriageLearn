import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from './pool.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const schema = await fs.readFile(path.join(__dirname, 'schema.sql'), 'utf8');
const seed = await fs.readFile(path.join(__dirname, 'seed.sql'), 'utf8');

try {
  await pool.query(schema);
  await pool.query(seed);
  console.log('TriageLearn database schema and technical demo seed are ready.');
} catch (error) {
  console.error('Database setup failed:', error.message);
  process.exitCode = 1;
} finally {
  await pool.end();
}
