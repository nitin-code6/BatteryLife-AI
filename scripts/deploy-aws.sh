#!/usr/bin/env bash
# ==============================================================================
# BatteryLife AI - Automated AWS EC2 Deployment Script
# ==============================================================================

set -e

echo "=== [1/5] Updating system packages and installing prerequisites ==="
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release git

echo "=== [2/5] Installing Docker and Docker Compose ==="
if ! command -v docker &> /dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker "$USER"
fi

# Detect public IP of the EC2 instance
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || curl -s ifconfig.me || echo "localhost")
echo "Detected Public IP: $PUBLIC_IP"

echo "=== [3/5] Configuring Environment Files ==="

# Backend .env
cat <<EOF > backend/.env
PORT=4000
JWT_SECRET=8fe3fa5bf31ba070ecba2af9f60c5be32bd7f7440b8a150ee8a0ed49b4d57f1d
MONGODB_URI=mongodb+srv://nitin_code:nitincode@codindadda.jvtcgmz.mongodb.net/battery_ai?retryWrites=true&w=majority
AI_SERVICE_URL=http://ai-service:8000
EOF

# Frontend .env (Points to the EC2 Public IP for browser access)
cat <<EOF > frontend/.env
NEXT_PUBLIC_API_BASE_URL=http://${PUBLIC_IP}:4000
EOF

# AI Service .env
cat <<EOF > ai-service/.env
HOST=0.0.0.0
PORT=8000
ENVIRONMENT=production
EOF

echo "=== [4/5] Building and Launching Docker Containers ==="
sudo docker compose down --remove-orphans || true
sudo docker compose up -d --build

echo "=== [5/5] Deployment Finished Successfully! ==="
echo "--------------------------------------------------------"
echo "Frontend Dashboard: http://${PUBLIC_IP}:3000"
echo "Backend API:        http://${PUBLIC_IP}:4000"
echo "AI Service Docs:    http://${PUBLIC_IP}:8000/docs"
echo "--------------------------------------------------------"
