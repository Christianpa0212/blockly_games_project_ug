// import object router from express to create routes 
import { Router } from "express";
import sessionRoutes from './session/sessionRoutes.js';

const router = Router();

// session routes
router.use(sessionRoutes);

// create a router object
export const routes = Router();


