#!/bin/bash

# Script d'installation et configuration de Metabase pour n8n
echo "🚀 Configuration de Metabase pour n8n..."

# Vérifier si les variables d'environnement sont définies
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL n'est pas défini"
    exit 1
fi

# Extraire les informations de connexion de DATABASE_URL
# Format: postgresql://user:password@host:port/database
DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DATABASE_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DATABASE_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

echo "📊 Configuration de la base de données:"
echo "  - Hôte: $DB_HOST"
echo "  - Port: $DB_PORT"
echo "  - Base: $DB_NAME"
echo "  - Utilisateur: $DB_USER"

# Créer les vues SQL pour Metabase
echo "🔧 Création des vues SQL pour Metabase..."
psql $DATABASE_URL -f metabase-views.sql

if [ $? -eq 0 ]; then
    echo "✅ Vues SQL créées avec succès!"
else
    echo "❌ Erreur lors de la création des vues SQL"
    exit 1
fi

echo "🎉 Configuration Metabase terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Déployez le service Metabase sur Render"
echo "2. Accédez à https://metabase-a6u8.onrender.com"
echo "3. Configurez le premier administrateur"
echo "4. Connectez-vous à la base de données PostgreSQL"
echo "5. Importez les vues dans Metabase"
echo ""
echo "🔗 URLs importantes:"
echo "- n8n: https://n8n-a6u8.onrender.com"
echo "- Metabase: https://metabase-a6u8.onrender.com"
