import { Router } from 'express';
import { sessionStart, sessionEnd } from '../../controllers/session/sessionControllers.js';

const router = Router();

/**
 * Rutas de sesión
 * - /session/start: iniciar sesión
 * - /session/end: cerrar sesión
 */
router.post('/session/start', sessionStart);
router.post('/session/end', sessionEnd);

export default router;
