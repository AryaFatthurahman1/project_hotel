# QuantumForge Hybrid Systems - Setup & Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development](#local-development)
3. [Docker Setup](#docker-setup)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [Cloud Provider Setup](#cloud-provider-setup)
6. [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

#### Local Development

```bash
# Operating System
- macOS 12+, Linux (Ubuntu 22.04+), or Windows 11 with WSL2

# Hardware Minimum
- CPU: 8 cores (16+ recommended)
- RAM: 16GB (32GB+ recommended for quantum simulators)
- Disk: 50GB SSD minimum

# Development Tools
- Git 2.40+
- Docker 24.0+ & Docker Compose 2.20+
- Kubernetes (kubectl 1.28+, kind/minikube for local testing)
```

#### Language Runtimes

```bash
# Python
python --version  # 3.11.0+
pip install pipenv poetry

# Node.js / TypeScript
node --version   # 20.10+
npm --version    # 10.0+

# Kotlin / Java
java -version    # OpenJDK 21+
kotlinc -version # 1.9.0+

# Go
go version      # 1.21+

# Rust
rustc --version # 1.75+
cargo --version # 1.75+
```

### Cloud Credentials

```bash
# AWS
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Azure
az login
az account set --subscription "subscription-id"

# Google Cloud
gcloud auth login
gcloud config set project PROJECT_ID
```

### Quantum Provider Access

```bash
# IBM Quantum
export IBM_QUANTUM_TOKEN="your-ibm-token"

# AWS Braket
export AWS_BRAKET_REGION="us-west-1"

# D-Wave Leap
export DWAVE_API_TOKEN="your-dwave-token"

# Quantinuum
export QUANTINUUM_API_KEY="your-quantinuum-key"
```

---

## Local Development

### 1. Clone & Setup Repository

```bash
# Clone the repository
git clone https://github.com/AryaFatthurahman1/project_hotel.git
cd project_hotel

# Create and checkout feature branch
git checkout -b quantum-hybrid-systems

# Create development directories
mkdir -p .env.local
touch .env.local/.env.development
```

### 2. Environment Configuration

Create `.env.local/.env.development`:

```bash
# Application
APP_NAME=quantum-hybrid-systems
APP_ENV=development
APP_DEBUG=true
APP_PORT=8080
APP_LOG_LEVEL=debug

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=quantum_dev
DB_USER=quantum_user
DB_PASSWORD=dev_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# Kafka
KAFKA_BROKER=localhost:9092
KAFKA_TOPIC_PREFIX=quantum-dev

# Quantum Providers
QUANTUM_PROVIDER=ibm
IBM_QUANTUM_TOKEN=${IBM_QUANTUM_TOKEN}
AWS_BRAKET_REGION=us-west-1
DWAVE_API_TOKEN=${DWAVE_API_TOKEN}

# API Keys
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

# Storage
S3_BUCKET=quantum-hybrid-dev
S3_REGION=us-east-1

# Monitoring
GRAFANA_ADMIN_PASSWORD=admin123
PROMETHEUS_RETENTION=15d
```

### 3. Install Dependencies

```bash
# Python dependencies
pip install --upgrade pip setuptools wheel
pip install poetry
poetry install

# Node.js dependencies
npm install -g yarn pnpm
cd frontend/next-app
pnpm install

# Go dependencies
go mod download
go mod verify

# Rust dependencies
rustup update
cargo fetch
```

### 4. Start Local Development Stack

```bash
# Using Docker Compose for services
docker-compose -f docker-compose.dev.yml up -d

# Wait for services to be healthy
docker-compose -f docker-compose.dev.yml ps

# Expected output:
# NAME                          STATUS
# quantum-postgres              Up (healthy)
# quantum-redis                 Up (healthy)
# quantum-kafka                 Up (healthy)
# quantum-prometheus            Up (healthy)
```

### 5. Run Development Servers

**Terminal 1 - Backend Services**:
```bash
# Start Kotlin Spring Boot service
cd backend/kotlin-services
./gradlew bootRun

# Expected: Started on port 8081
```

**Terminal 2 - FastAPI Quantum Orchestrator**:
```bash
cd backend/python-api
uvicorn main:app --reload --port 5000

# Expected: Uvicorn running on http://127.0.0.1:5000
```

**Terminal 3 - Frontend**:
```bash
cd frontend/next-app
pnpm dev

# Expected: http://localhost:3000
```

**Terminal 4 - Go Services**:
```bash
cd backend/go-services
go run ./cmd/api
go run ./cmd/cli

# Expected: HTTP server on port 8082
```

### 6. Verify Setup

```bash
# Test API connectivity
curl http://localhost:8080/api/v1/health

# Expected response:
# {"status":"healthy","version":"1.0.0","timestamp":"2026-05-10T12:34:56Z"}

# Test Quantum Orchestrator
curl -X POST http://localhost:5000/quantum/status

# Access Frontend
open http://localhost:3000

# Access Grafana Dashboards
open http://localhost:3000/grafana
# Username: admin, Password: admin123
```

---

## Docker Setup

### Docker Compose Configuration

Create `docker-compose.dev.yml`:

```yaml
version: '3.9'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: quantum-postgres
    environment:
      POSTGRES_USER: quantum_user
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: quantum_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U quantum_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: quantum-redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Apache Kafka
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    container_name: quantum-kafka
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
    ports:
      - "9092:9092"
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions.sh", "--bootstrap-server", "localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    container_name: quantum-zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  # Prometheus Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: quantum-prometheus
    volumes:
      - ./infrastructure/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  # Grafana Dashboards
  grafana:
    image: grafana/grafana:latest
    container_name: quantum-grafana
    depends_on:
      - prometheus
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin123
      GF_USERS_ALLOW_SIGN_UP: 'false'
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./infrastructure/grafana/provisioning:/etc/grafana/provisioning

  # ELK Stack - Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    container_name: quantum-elasticsearch
    environment:
      discovery.type: single-node
      xpack.security.enabled: 'false'
      ES_JAVA_OPTS: "-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  # ELK Stack - Kibana
  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    container_name: quantum-kibana
    depends_on:
      - elasticsearch
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_URL: http://elasticsearch:9200

  # Jaeger Tracing
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: quantum-jaeger
    ports:
      - "6831:6831/udp"
      - "16686:16686"

volumes:
  postgres_data:
  prometheus_data:
  grafana_data:
  elasticsearch_data:

networks:
  default:
    name: quantum-network
```

### Build Docker Images

```bash
# Build all service images
docker build -f backend/kotlin-services/Dockerfile -t quantum-kotlin-service:latest .
docker build -f backend/python-api/Dockerfile -t quantum-orchestrator:latest .
docker build -f backend/go-services/Dockerfile -t quantum-go-service:latest .
docker build -f backend/rust-accelerators/Dockerfile -t quantum-accelerator:latest .

# Build frontend image
docker build -f frontend/next-app/Dockerfile -t quantum-frontend:latest .

# Verify images
docker images | grep quantum
```

---

## Kubernetes Deployment

### 1. Create Kubernetes Cluster

#### Using AWS EKS

```bash
# Create cluster with eksctl
eksctl create cluster \
  --name quantum-hybrid-systems \
  --region us-east-1 \
  --nodegroup-name ng-primary \
  --node-type t3.xlarge \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 10

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

#### Using Azure AKS

```bash
# Create resource group
az group create \
  --name quantum-rg \
  --location eastus

# Create AKS cluster
az aks create \
  --resource-group quantum-rg \
  --name quantum-cluster \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard

# Get credentials
az aks get-credentials \
  --resource-group quantum-rg \
  --name quantum-cluster
```

#### Using Local minikube

```bash
# Start minikube
minikube start --cpus 8 --memory 16384 --disk-size 50GB

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard
```

### 2. Deploy Application

```bash
# Create namespace
kubectl create namespace quantum-hybrid-systems

# Label namespace for monitoring
kubectl label namespace quantum-hybrid-systems monitoring=enabled

# Deploy using Helm
helm repo add quantum-charts https://charts.quantum-hybrid-systems.io
helm repo update

helm install quantum-platform quantum-charts/quantum-platform \
  --namespace quantum-hybrid-systems \
  --values helm/values-dev.yaml

# Verify deployment
kubectl get pods -n quantum-hybrid-systems
kubectl get services -n quantum-hybrid-systems
```

### 3. Configure Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: quantum-ingress
  namespace: quantum-hybrid-systems
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - api.quantum-hybrid-systems.com
    - app.quantum-hybrid-systems.com
    secretName: quantum-tls
  rules:
  - host: api.quantum-hybrid-systems.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 8080
  - host: app.quantum-hybrid-systems.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 3000
```

Apply ingress:
```bash
kubectl apply -f ingress.yaml -n quantum-hybrid-systems
```

---

## Cloud Provider Setup

### AWS Configuration

```bash
# Create S3 bucket for artifacts
aws s3 mb s3://quantum-hybrid-systems-artifacts --region us-east-1

# Create RDS PostgreSQL database
aws rds create-db-instance \
  --db-instance-identifier quantum-db-prod \
  --db-instance-class db.t3.large \
  --engine postgres \
  --master-username quantum_admin \
  --master-user-password $(openssl rand -base64 32) \
  --allocated-storage 100

# Create ElastiCache Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id quantum-redis-prod \
  --cache-node-type cache.t3.medium \
  --engine redis \
  --num-cache-nodes 3
```

### Azure Configuration

```bash
# Create resource group
az group create \
  --name quantum-prod-rg \
  --location eastus

# Create container registry
az acr create \
  --resource-group quantum-prod-rg \
  --name quantumregistryprod \
  --sku Premium

# Create CosmosDB for vector embeddings
az cosmosdb create \
  --name quantum-cosmosdb \
  --resource-group quantum-prod-rg \
  --capabilities EnableServerless
```

### GCP Configuration

```bash
# Create GCS bucket
gsutil mb -p quantum-hybrid-systems gs://quantum-hybrid-artifacts

# Create Cloud SQL PostgreSQL instance
gcloud sql instances create quantum-db-prod \
  --database-version=POSTGRES_15 \
  --tier=db-custom-4-16384 \
  --region=us-central1

# Create Firestore database
gcloud firestore databases create --location=us-central1
```

---

## CI/CD Pipeline Configuration

### GitHub Actions Workflow

Create `.github/workflows/deploy-quantum.yml`:

```yaml
name: Deploy QuantumForge

on:
  push:
    branches:
      - main
      - staging
  pull_request:
    branches:
      - main

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run Python tests
        run: pytest --cov

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install frontend deps
        run: |
          cd frontend/next-app
          pnpm install

      - name: Run frontend tests
        run: pnpm test

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Run Go tests
        run: go test ./...

      - name: Set up Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Run Rust tests
        run: cargo test

  build:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker images
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Configure kubectl
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config

      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/quantum-orchestrator \
            quantum-orchestrator=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            -n quantum-hybrid-systems
          
          kubectl rollout status deployment/quantum-orchestrator \
            -n quantum-hybrid-systems --timeout=5m

      - name: Run smoke tests
        run: |
          kubectl run quantum-smoke-test \
            --image=quantum-test:latest \
            --rm -i --restart=Never \
            -n quantum-hybrid-systems
```

---

## Troubleshooting

### Common Issues

**Issue: PostgreSQL connection failed**
```bash
# Check if container is running
docker ps | grep postgres

# View logs
docker logs quantum-postgres

# Reconnect and test
docker exec quantum-postgres psql -U quantum_user -d quantum_dev -c "SELECT 1;"
```

**Issue: Kafka broker not responding**
```bash
# Check Kafka container
docker logs quantum-kafka

# Test Kafka connectivity
docker exec quantum-kafka kafka-broker-api-versions.sh \
  --bootstrap-server localhost:9092
```

**Issue: Kubernetes pod stuck in pending**
```bash
# Describe the pod to see events
kubectl describe pod <pod-name> -n quantum-hybrid-systems

# Check node resources
kubectl top nodes
kubectl top pods -n quantum-hybrid-systems

# Check storage class availability
kubectl get storageclass
```

### Health Checks

```bash
# Check all services health
curl http://localhost:8080/api/v1/health
curl http://localhost:5000/health
curl http://localhost:8082/health

# Check database connectivity
psql -h localhost -U quantum_user -d quantum_dev -c "SELECT NOW();"

# Check Redis connectivity
redis-cli -h localhost PING

# Check Kafka topics
kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## Next Steps

1. Review [ARCHITECTURE.md](./ARCHITECTURE.md) for system design details
2. Check [API_REFERENCE.md](./API_REFERENCE.md) for API documentation
3. Read [QUANTUM_GUIDE.md](./QUANTUM_GUIDE.md) for quantum programming examples
4. Review CI/CD setup in `.github/workflows/`

For questions or issues, please open an issue on GitHub.

