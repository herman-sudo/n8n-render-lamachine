#!/bin/sh

# Script de démarrage n8n avec configuration PostgreSQL explicite
echo "🚀 Démarrage de n8n avec PostgreSQL..."
echo ""

# Charger les variables d'environnement si le fichier .env existe (utile pour le local)
if [ -f .env ]; then
  echo "📄 Chargement du fichier .env..."
  export $(grep -v '^#' .env | xargs)
fi

# Afficher la configuration (sans les mots de passe)
echo "📋 Configuration:"
echo "  DB_TYPE: ${DB_TYPE}"
echo "  N8N_DB_TYPE: ${N8N_DB_TYPE}"
echo "  DATABASE_URL: ${DATABASE_URL:+***SET***}"
echo "  Host: ${N8N_DB_POSTGRESDB_HOST}"
echo "  Port: ${N8N_DB_POSTGRESDB_PORT}"
echo "  Database: ${N8N_DB_POSTGRESDB_DATABASE}"
echo "  User: ${N8N_DB_POSTGRESDB_USER}"
echo ""

# Forcer l'utilisation de PostgreSQL
export DB_TYPE=postgresdb
export N8N_DB_TYPE=postgresdb

# Si DATABASE_URL est défini, l'utiliser
if [ -n "$DATABASE_URL" ]; then
    echo "✅ Utilisation de DATABASE_URL pour la connexion PostgreSQL"
    export DB_POSTGRESDB_DATABASE=$(echo $DATABASE_URL | sed 's/.*\/\([^?]*\).*/\1/')
    export DB_POSTGRESDB_HOST=$(echo $DATABASE_URL | sed 's/.*@\([^:]*\):.*/\1/')
    export DB_POSTGRESDB_PORT=$(echo $DATABASE_URL | sed 's/.*:\([0-9]*\)\/.*/\1/')
    export DB_POSTGRESDB_USER=$(echo $DATABASE_URL | sed 's/.*:\/\/\([^:]*\):.*/\1/')
    export DB_POSTGRESDB_PASSWORD=$(echo $DATABASE_URL | sed 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')
    
    # Aussi pour n8n
    export N8N_DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE
    export N8N_DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST
    export N8N_DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT
    export N8N_DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER
    export N8N_DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD
    
    echo "  Extracted Host: $DB_POSTGRESDB_HOST"
    echo "  Extracted Port: $DB_POSTGRESDB_PORT"
    echo "  Extracted Database: $DB_POSTGRESDB_DATABASE"
    echo "  Extracted User: $DB_POSTGRESDB_USER"
fi

echo ""
# Vérifier si n8n est installé globalement ou localement
if command -v n8n >/dev/null 2>&1; then
    N8N_CMD="n8n"
elif [ -f "./node_modules/.bin/n8n" ]; then
    N8N_CMD="./node_modules/.bin/n8n"
else
    echo "❌ CRITICAL ERROR: n8n executable not found!"
    exit 1
fi

echo "✅ Found n8n: $N8N_CMD"

# Vérifier la connexion à la base de données avant de démarrer
if [ -f "./check-db-connection.js" ]; then
    echo "🔍 Running Pre-flight DB Check..."
    node check-db-connection.js
    if [ $? -eq 0 ]; then
        echo "✅ DB Check Passed."
    else
        echo "⚠️ DB Check Failed or Warning. Proceeding anyway but check logs."
    fi
fi

# Démarrer n8n avec les variables d'environnement
echo "🔄 Lancement de n8n..."
exec $N8N_CMD start
