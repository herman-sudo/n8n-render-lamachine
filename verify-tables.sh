#!/bin/bash

# Script pour vérifier les tables n8n dans Supabase
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "🔍 Vérification des tables n8n dans Supabase..."
echo ""

# Compter toutes les tables
echo "📊 Nombre total de tables dans la base:"
psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"

echo ""
echo "📋 Tables n8n principales:"
psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND (table_name LIKE 'workflow%' OR table_name LIKE 'execution%' OR table_name LIKE 'credentials%' OR table_name LIKE 'user%' OR table_name = 'agent' OR table_name LIKE 'chat_hub%') ORDER BY table_name;"

echo ""
echo "📈 Statistiques:"
psql "$DATABASE_URL" -c "SELECT 
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'workflow%') as workflows_tables,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'execution%') as execution_tables,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'chat_hub%') as chat_tables,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') as total_tables;"
