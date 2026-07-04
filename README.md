
        ```markdown
        # DevOps Project 1 — Flask Todo App

        ![CI/CD](https://github.com/Tiffea/devops_project1/actions/workflows/build.yml/badge.svg)

        ## Overview
        Production-ready Flask todo app with full DevOps pipeline: CI/CD, containerisation, 
        Kubernetes orchestration, monitoring, and infrastructure as code.

        ## Architecture
        ```
        Client → Nginx → Flask (Gunicorn) → PostgreSQL
                        ↓
                Prometheus → Grafana
        ```

        ## Tech Stack
        | Layer | Tools |
        |-------|-------|
        | App | Python / Flask / Gunicorn |
        | Containerisation | Docker / Docker Compose |
        | Orchestration | Kubernetes / Helm / ArgoCD |
        | CI/CD | GitHub Actions |
        | Infrastructure | Terraform / Ansible |
        | Monitoring | Prometheus / Grafana |
        | Cloud | AWS EC2 |

        ## Project Structure
        ```
        ├── app/          # Flask application
        ├── infra/        # Terraform + Ansible roles
        ├── k8s/          # Helm chart + ArgoCD
        └── monitoring/   # Prometheus config
        ```

        ## CI/CD Pipeline
        On every push to main:
        1. Build Docker image
        2. Push to Docker Hub
        3. Deploy to AWS EC2 via Ansible

        ## Infrastructure
        Terraform provisions:
        - AWS EC2 (t3.micro, Ubuntu)
        - Security Group (ports 22/80/5000)

        Ansible roles:
        - common → system packages
        - docker → Docker installation
        - nginx  → reverse proxy
        - app    → application deployment

        ## Local Development
        ```bash
        git clone https://github.com/Tiffea/devops_project1
        cd devops_project1
        docker compose up --build
        ```

        ## Kubernetes (local)
        ```bash
        minikube start
        helm install devops-project1 ./k8s/helm/my-app
        ```
        ```






-------------------------------

новый README

 - thhp модуль добавил чтобы можно было входить по ssh только со своего пк
 для меня это лусше чем ssm сейчас потому что удобнее + не ограничено системой amazon
