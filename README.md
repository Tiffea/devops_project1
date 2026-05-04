# DevOps Flask App

![CI/CD](https://github.com/Tiffea/devops_project1/actions/workflows/build.yml/badge.svg)

## Overview
Flask app with CI/CD, containerisation, monitoring, and infrastructure automation.

## Architecture
Client → Ingress → Service → Pods (Flask app)

Monitoring:
- Prometheus scrapes metrics
- Grafana visualisation

## Tech Stack
- Python (Flask)
- Docker / Docker Compose
- Kubernetes (k3s, local)
- Terraform
- GitHub Actions
- AWS EC2

## CI/CD
On every push:
1. Build Docker image
2. Run tests
3. (Optional) push image

## Terraform
Provisions AWS EC2 instance (t3.micro).

Creates:
- EC2 instance (Ubuntu)
- Security group (inbound/outbound rules)

Note:
App is not deployed automatically.