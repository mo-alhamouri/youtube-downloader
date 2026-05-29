# Use a Node.js base image
FROM node:20-slim

# Install system dependencies: python3 (for yt-dlp) and ffmpeg
RUN apt-get update && apt-get install -y \
    python3 \
    curl \
    ffmpeg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Deno (preferred JS runtime for yt-dlp)
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

WORKDIR /app

# Copy package files for root, backend, and frontend
COPY package*.json ./
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Install all dependencies
RUN npm install
RUN npm install --prefix backend
RUN npm install --prefix frontend

# Copy the rest of the application code
COPY . .

# Build the frontend production assets
RUN cd frontend && npm run build

# Expose the backend port
EXPOSE 5001

# Start the backend server
# We use 'npm start' in the backend which runs 'node server.js'
CMD ["npm", "--prefix", "backend", "start"]
