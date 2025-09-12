// import library to load environment variables from .env file
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

// Configuration object for environment variables
export const env = {
  port: process.env.PORT || 3000,
  db: {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  }
};
