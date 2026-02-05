FROM node:20-alpine

# Install Python 3 and dependencies
RUN apk add --no-cache python3 py3-pip make g++ && \
    npm install -g n8n@2.4.8 && \
    echo "n8n version: $(n8n --version)"

# Set working directory
WORKDIR /data

# Copy package files
COPY package*.json ./
RUN npm install --force

# Copy application
COPY . .

# Expose port
EXPOSE 5678

# Start n8n with explicit database configuration
CMD ["sh", "-c", "n8n start --database=postgresdb --database-host=$N8N_DB_POSTGRESDB_HOST --database-port=$N8N_DB_POSTGRESDB_PORT --database-name=$N8N_DB_POSTGRESDB_DATABASE --database-user=$N8N_DB_POSTGRESDB_USER --database-password=$N8N_DB_POSTGRESDB_PASSWORD"]
