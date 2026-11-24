#!/usr/bin/env bash
# ==============================================================================
# BatteryLife AI - Automated AWS EC2 Deployment Script
# ==============================================================================

set -e

echo "=== [1/4] Installing Docker and system packages ==="
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose-v2 git curl
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER" || true

# Detect public IP of the EC2 instance
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || curl -s ifconfig.me || echo "15.134.206.166")
echo "Detected Public IP: $PUBLIC_IP"

echo "=== [2/4] Configuring Environment Files ==="

# Backend .env
cat <<EOF > backend/.env
PORT=4000
JWT_SECRET=8fe3fa5bf31ba070ecba2af9f60c5be32bd7f7440b8a150ee8a0ed49b4d57f1d
MONGODB_URI=mongodb+srv://nitin_code:nitincode@codindadda.jvtcgmz.mongodb.net/battery_ai?retryWrites=true&w=majority
AI_SERVICE_URL=http://ai-service:8000
EOF

# Frontend .env
cat <<EOF > frontend/.env
NEXT_PUBLIC_API_BASE_URL=http://${PUBLIC_IP}:4000
EOF

# AI Service .env
cat <<EOF > ai-service/.env
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
EOF

echo "=== [3/4] Building and Launching Docker Containers ==="
sudo docker compose -f docker-compose.prod.yml down --remove-orphans || true
sudo docker compose -f docker-compose.prod.yml up -d --build

echo "=== [4/4] Deployment Finished Successfully! ==="
echo "--------------------------------------------------------"
echo "Frontend Dashboard: http://${PUBLIC_IP}:3000"
echo "Backend API:        http://${PUBLIC_IP}:4000"
echo "AI Service Docs:    http://${PUBLIC_IP}:8000/docs"
echo "--------------------------------------------------------"
