import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

import routes from "./src/routes/routes.js";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for JSON parsing
app.use(express.json());

// Serve static files 
app.use(express.static(path.join(__dirname, "../client/public"), {
  extensions: ["html"], 
}));

// Routes 
app.use("/", routes);

// Server start
app.listen(PORT, () => {
  console.log(`Server running in:  http://localhost:${PORT}`);
});
