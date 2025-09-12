import { Router } from 'express';
import { partidaStart, partidaEnd, eventoAdd } from '../../controllers/partida/partidaControllers.js';

const router = Router();

/**
 * Rutas de partida
 * - /partida/start: inicia partida
 * - /partida/end: cerrar partida
 * - /partida/event: registrar evento en partida
 */
router.post('/partida/start', partidaStart);
router.post('/partida/end', partidaEnd);
router.post('/partida/event', eventoAdd);

export default router;
