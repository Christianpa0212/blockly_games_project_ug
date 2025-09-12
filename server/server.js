// Call variable express for initilize server
import express from "express";

// Call archive variables environment
import { env } from "./src/config/env/env.js";


import path from "path";
import { fileURLToPath } from "url";


// Call archive for all Routes 
import { routes } from "./src/routes/routes.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define function for initilize server
const app = express();


// Middleware for JSON parsing
app.use(express.json());

// Serve static files for frontend 
app.use(express.static(path.join(__dirname, "../client/public"), {
  extensions: ["html"], 
}));

// Call Routes 
app.use("/", routes);

// Server start
app.listen(env.port, () => {
  const port = env.port;
  console.log(`Server running in:  http://localhost:${port}`);
});
