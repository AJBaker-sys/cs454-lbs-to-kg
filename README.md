# Project 1: Pounds to Kilograms REST Service
This project deploys a simple REST API on AWS EC2 using Docker. The API converts pounds (lbs) to kilograms (kg) via a GET endpoint. Built with Flask, containerized with Docker, and served behind an Nginx reverse proxy.

## Features
- API Endpoint: GET /convert?lbs=\<float> returns {"lbs": \<float>, "kg": \<float>, "formula": "..."}.
- Error Handling: Validates input, returns 400/422 for invalid/negative inputs.
- Gunicorn for WSGI, Nginx for proxying, healthchecks for reliability.
- Web Interface: Input field for lbs, displays kg result via AJAX.
  
## Setup Steps
### Step 1: Launch EC2 (Easy Console Way)
- Go to AWS Console > EC2 > Launch Instance.
- Name: cs454-p1
- AMI: Ubuntu 22.04 LTS (free tier). (This is just an example; anything works)
- Instance type: t2.micro (free).
- Key pair: Create new (download .pem file).
- Security Group: Create new—allow:
  - SSH (port 22) from "My IP" only.
  - HTTP (80) from Anywhere (0.0.0.0/0).
- Launch. Wait for running. Copy Public IPv4 IP.

### Step 2: SSH to EC2
- On your machine: `chmod 400 your-key.pem`
- Connect: `ssh -i my-key.pem ubuntu@<EC2-PUBLIC-IP>`

### Step 3: Install Dependencies
- sudo apt update && sudo apt upgrade -y
- sudo apt install -y docker.io docker-compose git
- sudo usermod -aG docker ubuntu && newgrp docker

### Step 4: Clone and Deploy
- git clone https://github.com/AJBaker-sys/cs454-lbs-to-kg.git
- cd cs454-lbs-to-kg
- docker-compose up --build -d

### Access
- Web UI: http://\<EC2-PUBLIC-IP>
- API: curl "http://\<EC2-PUBLIC-IP>/convert?lbs=150"
    - Response: {"lbs":150.0,"kg":68.039,"formula":"kg = lbs * 0.45359237"}

### Management
- View logs: docker-compose logs -f
- Stop services: docker-compose down
- Enable Docker on boot: sudo systemctl enable docker

### Testing
Public URL: http://\<PUBLIC_IP>/convert?lbs=150 (or https if setup).
Examples:
- Normal: `curl 'http://\<PUBLIC_IP>/convert?lbs=150'` → `{"lbs":150.0,"kg":68.039,"formula":"kg = lbs * 0.45359237"}`
- Zero: `curl 'http://\<PUBLIC_IP>/convert?lbs=0'` → `{"lbs":0.0,"kg":0.0,"formula":"kg = lbs * 0.45359237"}`
- Edge: `curl 'http://\<PUBLIC_IP>/convert?lbs=0.1'` → `{"lbs":0.1,"kg":0.045,"formula":"kg = lbs * 0.45359237"}`
- Error missing: `curl 'http://\<PUBLIC_IP>/convert'` → 400 JSON error
- Error negative: `curl 'http://\<PUBLIC_IP>/convert?lbs=-5'` → 422 JSON error
- Error NaN: `curl 'http://\<PUBLIC_IP>/convert?lbs=NaN'` → 400 JSON error

I made a simple script for convenience you can just run
    `cd app` then `.\run_tests` (you can specify an ip or default to localhost)

### Cleanup & Cost Hygiene
To stop and remove containers, networks, and images:
 - cd cs454-lbs-to-kg
 - docker-compose down --rmi all

To reclaim disk space, remove unused Docker data:
 - docker system prune -f

Terminate EC2: AWS Console > EC2 > Instances > Terminate. Delete key pair, security group if orphaned. Check for EBS volumes.

## Public Endpoint
- URL: https://\<PUBLIC_IP>
- Security Group Summary: Inbound - SSH:22 (your IP), HTTP:80 (all). Least privilege applied.

## Screenshots
(Include in submission: curl success/error, docker logs, AWS Security Group console shot)

## Video Demo
(Link here)
