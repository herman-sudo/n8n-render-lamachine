FROM node:18-alpine

# Install dependencies
RUN npm install -g n8n

# Set working directory
WORKDIR /data

# Copy package files
COPY package*.json ./
RUN npm install

# Copy application
COPY . .

# Expose port
EXPOSE 5678

# Start n8n with tunnel
CMD ["n8n", "start", "--tunnel"]
