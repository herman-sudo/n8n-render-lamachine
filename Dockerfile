FROM n8nio/n8n:latest

# Configuration pour Render
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV N8N_HOST=0.0.0.0

# Forcer IPv4 pour éviter les problèmes de connexion
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

CMD ["/usr/local/bin/n8n", "start"]
