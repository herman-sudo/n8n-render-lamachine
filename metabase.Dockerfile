FROM metabase/metabase:latest

# Expose le port par défaut de Metabase
EXPOSE 3000

# Variables d'environnement par défaut
ENV MB_DB_TYPE=postgres
ENV MB_DB_PORT=5432

# Démarrage de Metabase
CMD ["java", "-jar", "/app/metabase.jar"]
