# DevOps Flask App

![CI/CD](https://github.com/Tiffea/devops_project1/actions/workflows/build.yml/badge.svg)

## Overview
Flask app with CI/CD, containerisation, monitoring, and infrastructure automation.

## Quick Start
\```bash
git clone https://github.com/Tiffea/devops_project1
cd devops_project1
docker compose up --build
\```

## Architecture
Client → Nginx → Flask (Gunicorn) → PostgreSQL
                      ↓
              Prometheus → Grafana

## Tech Stack
- Python (Flask)
- Docker / Docker Compose
- Kubernetes (Kubernetes manifests tested locally with minikube)
- Terraform
- GitHub Actions
- AWS EC2

## CI/CD
On every push:
1. Build an image
2. Push image to Docker Hub
3. Deploy to server via SSH

## Terraform
Provisions AWS EC2 instance (t3.micro).

Creates:
- EC2 instance (Ubuntu)
- Security group (inbound/outbound rules)

Note:
App is not deployed automatically.