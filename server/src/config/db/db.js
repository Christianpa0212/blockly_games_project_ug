// Import mysql2 library
import mysql from "mysql2/promise";

// Import object with environment variables
import { env } from "../env/env.js";

// Define variables for connection pool 
export const pool = mysql.createPool({
  host: env.db.host,
  port: env.db.port,
  user: env.db.user,
  password: env.db.password,
  database: env.db.database,
  waitForConnections: true,
  connectionLimit: 10,   
  queueLimit: 0          
});