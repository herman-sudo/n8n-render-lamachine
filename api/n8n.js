const express = require("express");
const { exec } = require("child_process");

const app = express();
const port = process.env.PORT || 5678;

// Middleware
app.use(express.json());

// Configuration n8n avec Supabase
const n8nConfig = {
  DATABASE_URL: process.env.DATABASE_URL,
  N8N_LOG_LEVEL: process.env.N8N_LOG_LEVEL || "info",
  GENERIC_TIMEZONE: process.env.GENERIC_TIMEZONE || "Europe/Paris",
  TZ: process.env.TZ || "Europe/Paris",
  N8N_DEFAULT_LOCALE: process.env.N8N_DEFAULT_LOCALE || "fr",
  N8N_ENCRYPTION_KEY: process.env.N8N_ENCRYPTION_KEY,
  WEBHOOK_URL: process.env.WEBHOOK_URL,
  PORT: port,
};

// Routes de base
app.get("/", (req, res) => {
  res.json({
    message: "n8n running on Render with Supabase",
    status: "active",
    n8n_version: "latest",
    config: {
      database: n8nConfig.DATABASE_URL ? "configured" : "missing",
      encryption: n8nConfig.N8N_ENCRYPTION_KEY ? "configured" : "missing",
      webhook_url: n8nConfig.WEBHOOK_URL || "not set",
    },
  });
});

app.get("/healthz", (req, res) => {
  res.status(200).json({
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Route pour le cronjob (keep-alive)
app.get("/keep-alive", (req, res) => {
  console.log("Keep-alive ping received at:", new Date().toISOString());
  res.json({
    message: "Server kept alive",
    timestamp: new Date().toISOString(),
    next_ping: "15 minutes",
  });
});

// Démarrer n8n en arrière-plan
function startN8n() {
  const n8nCommand = `npx n8n start --tunnel`;

  exec(n8nCommand, (error, stdout, stderr) => {
    if (error) {
      console.error(`n8n start error: ${error}`);
      return;
    }
    console.log(`n8n stdout: ${stdout}`);
    if (stderr) {
      console.error(`n8n stderr: ${stderr}`);
    }
  });
}

// Démarrer le serveur Express
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log(`n8n configuration:`, n8nConfig);

  // Démarrer n8n après un court délai
  setTimeout(() => {
    console.log("Starting n8n...");
    startN8n();
  }, 5000);
});

module.exports = app;
