# AWS Cloud Deployment Guide

This guide walks you through deploying **BatteryLife AI** on **Amazon Web Services (AWS)** using an **EC2 Ubuntu instance** with Docker Compose and MongoDB Atlas.

---

## 1. Launch an AWS EC2 Instance

1. Log into your [AWS Management Console](https://console.aws.amazon.com/).
2. Navigate to **EC2** and click **Launch Instance**.
3. Configure the following settings:
   * **Name**: `BatteryLife-AI-Server`
   * **Amazon Machine Image (AMI)**: **Ubuntu Server 24.04 LTS** (Free tier eligible)
   * **Instance Type**: 
     * `t2.micro` (AWS Free Tier eligible) or `t3.small` / `t3.medium` (recommended for compiling PyTorch & Next.js builds).
   * **Key Pair**: Select an existing key pair or create a new one (download the `.pem` file).
   * **Network / Security Group**:
     Click **Edit** on Network Settings and ensure the following **Inbound Security Group Rules** are enabled:

| Type | Port Range | Source | Description |
| :--- | :--- | :--- | :--- |
| **SSH** | `22` | Anywhere (`0.0.0.0/0`) | Remote SSH console access |
| **Custom TCP** | `3000` | Anywhere (`0.0.0.0/0`) | Next.js Frontend Dashboard |
| **Custom TCP** | `4000` | Anywhere (`0.0.0.0/0`) | Express Backend API Gateway |
| **Custom TCP** | `8000` | Anywhere (`0.0.0.0/0`) | FastAPI AI Service & OpenAPI Docs |

4. Click **Launch Instance**.

---

## 2. Connect to Your EC2 Instance

Open your local terminal (PowerShell, Command Prompt, or Git Bash):

```bash
# Set permissions on your key file (Linux / Mac / Git Bash)
chmod 400 your-key.pem

# SSH into your EC2 instance
ssh -i "your-key.pem" ubuntu@<YOUR_EC2_PUBLIC_IP>
```

---

## 3. Run the Automated Deployment Script (1 Command)

Once logged into your EC2 server, simply copy and paste this command:

```bash
git clone https://github.com/nitin-code6/BatteryLife-AI.git && cd BatteryLife-AI && chmod +x scripts/deploy-aws.sh && ./scripts/deploy-aws.sh
```

### What this automated script does:
1. Installs Docker and Docker Compose on Ubuntu.
2. Automatically detects your EC2 instance's **Public IP**.
3. Configures all `.env` files with your **MongoDB Atlas cluster** and generated cryptographic **JWT Secret**.
4. Builds the multi-tier Docker containers in the background (`docker compose up -d --build`).

---

## 4. Access the Live Application

Open your browser and navigate to:

* **Frontend Dashboard**: `http://<YOUR_EC2_PUBLIC_IP>:3000`
* **Backend Gateway**: `http://<YOUR_EC2_PUBLIC_IP>:4000`
* **AI Service Interactive Docs**: `http://<YOUR_EC2_PUBLIC_IP>:8000/docs`

---

## 5. Maintenance Commands (on EC2)

```bash
# View live container logs
sudo docker compose logs -f

# Check container health and status
sudo docker compose ps

# Restart services
sudo docker compose restart

# Stop all services
sudo docker compose down
```
