// import object router from express to create routes 
import { Router } from "express";
import sessionRoutes from './session/sessionRoutes.js';
import partidaRoutes from './partida/partidaRoutes.js';

const router = Router();

// session routes
router.use(sessionRoutes);

// partida routes
router.use(partidaRoutes);

// create a router object
export const routes = router;


