#!/bin/sh

# Script de démarrage n8n avec configuration PostgreSQL explicite
echo "🚀 Démarrage de n8n avec PostgreSQL..."
echo ""

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
echo "🔄 Lancement de n8n..."
echo ""

# Démarrer n8n avec les variables d'environnement
exec n8n start
