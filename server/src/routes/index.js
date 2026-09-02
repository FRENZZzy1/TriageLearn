import { Router } from 'express';
import { register, login, logout, me } from '../controllers/auth.controller.js';
import { getProgress } from '../controllers/progress.controller.js';
import { getScenario, listScenarios, startScenario } from '../controllers/scenario.controller.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

router.get('/health', (req, res) => res.json({ status: 'ok', service: 'triagelearn-api' }));

router.post('/auth/register', register);
router.post('/auth/login', login);
router.post('/auth/logout', logout);
router.get('/auth/me', requireAuth, me);

router.get('/progress', requireAuth, requireRole('STUDENT'), getProgress);

router.get('/scenarios', requireAuth, requireRole('STUDENT', 'FACULTY'), listScenarios);
router.get('/scenarios/:id', requireAuth, requireRole('STUDENT', 'FACULTY'), getScenario);
router.post('/scenarios/:id/start', requireAuth, requireRole('STUDENT'), startScenario);

export default router;
