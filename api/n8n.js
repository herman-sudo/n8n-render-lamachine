const { exec } = require("child_process");
const express = require("express");

// Créer l'application Express
const app = express();

// Middleware pour parser le JSON
app.use(express.json());

// Configuration de n8n avec Supabase
const n8nConfig = {
  DATABASE_URL: process.env.DATABASE_URL,
  N8N_LOG_LEVEL: process.env.N8N_LOG_LEVEL || "info",
  GENERIC_TIMEZONE: process.env.GENERIC_TIMEZONE || "Europe/Paris",
  TZ: process.env.TZ || "Europe/Paris",
  N8N_DEFAULT_LOCALE: process.env.N8N_DEFAULT_LOCALE || "fr",
  N8N_ENCRYPTION_KEY: process.env.N8N_ENCRYPTION_KEY,
  WEBHOOK_URL: process.env.WEBHOOK_URL,
  PORT: process.env.PORT || 5678,
};

// Routes de base
app.get("/", (req, res) => {
  res.json({
    message: "n8n is running on Vercel with Supabase",
    status: "active",
    config: {
      database: n8nConfig.DATABASE_URL ? "configured" : "missing",
      encryption: n8nConfig.N8N_ENCRYPTION_KEY ? "configured" : "missing",
      webhook_url: n8nConfig.WEBHOOK_URL || "not set",
    },
  });
});

app.get("/healthz", (req, res) => {
  res.status(200).json({ status: "OK", timestamp: new Date().toISOString() });
});

// Route pour les webhooks n8n
app.post("/webhook/:path", (req, res) => {
  const { path } = req.params;
  res.json({
    message: "Webhook received",
    path: path,
    data: req.body,
    timestamp: new Date().toISOString(),
  });
});

// Route d'information n8n
app.get("/n8n", (req, res) => {
  res.json({
    message: "n8n interface - mode serverless",
    version: "1.0.0",
    features: ["webhooks", "api endpoints"],
    limitations: ["no background workers", "30s timeout"],
    webhook_base: `${n8nConfig.WEBHOOK_URL}/webhook`,
  });
});

// Export pour Vercel
module.exports = (req, res) => {
  app(req, res);
};
