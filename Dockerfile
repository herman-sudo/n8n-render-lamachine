FROM node:20-slim

# Install Python 3, build dependencies, and n8n
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    npm install -g n8n@2.4.8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
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

# Start n8n with PostgreSQL using environment variables
# The start script will display config and launch n8n
CMD ["./start-n8n.sh"]
