import { Router } from "express";

const router = Router();


// Ejemplo simple
router.get("/hello", (req, res) => {
  res.json({ message: "Hola desde la API 🚀" });
});



export default router;
