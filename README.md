# Azure DevOps CI/CD Pipeline Project

A complete end-to-end CI/CD implementation for a microservices voting application using Azure DevOps, Docker, Kubernetes, and Azure Container Registry (ACR). This project demonstrates automated builds, containerization, and GitOps-style deployment workflows.

## 🚀 Project Overview

This is a distributed voting application with automated CI/CD pipelines that:
- Builds Docker images using multi-stage builds
- Pushes images to Azure Container Registry (ACR)
- Automatically updates Kubernetes deployment manifests
- Deploys to Kubernetes clusters with zero manual intervention

## 🏗️ Example Voting App

A simple distributed application running across multiple Docker containers demonstrating microservices architecture with automated deployment pipelines.

## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.

Run in this directory to build and run the app:

```shell
docker compose up
```

The `vote` app will be running at [http://localhost:8080](http://localhost:8080), and the `results` will be at [http://localhost:8081](http://localhost:8081).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:

```shell
docker swarm init
```

Once you have your swarm, in this directory run:

```shell
docker stack deploy --compose-file docker-stack.yml vote
```

## 🎯 Run the app in Kubernetes

The folder `k8s-specifications` contains the YAML specifications of the Voting App's services.

### Prerequisites

1. **Azure Container Registry (ACR) Secret**: Create a Kubernetes secret for pulling images from ACR:
   ```shell
   kubectl create secret docker-registry acr-secret \
     --docker-server=yuvrajcr.azurecr.io \
     --docker-username=<ACR_USERNAME> \
     --docker-password=<ACR_PASSWORD> \
     --docker-email=<EMAIL>
   ```

2. **Kubernetes Cluster**: Ensure you have a Kubernetes cluster running and `kubectl` configured.

### Deploy to Kubernetes

Run the following command to create the deployments and services. Note it will create these resources in your current namespace (`default` if you haven't changed it.)

```shell
kubectl apply -f k8s-specifications/
```

### Access the Application

The services are configured with **LoadBalancer** type:

- **Vote Service**: Accessible via LoadBalancer external IP on port `8080`
- **Result Service**: Accessible via LoadBalancer external IP on port `8081`

To get the external IPs:
```shell
kubectl get svc vote result
```

### Remove Deployment

To remove all resources, run:

```shell
kubectl delete -f k8s-specifications/
```

## 🏛️ Architecture

![Architecture diagram](architecture.excalidraw.png)

### Application Components

* **Vote Service** ([Python](/vote)) - Front-end web app that lets users vote between two options
* **Redis** - In-memory data store that collects new votes as a message queue
* **Worker Service** ([.NET](/worker)) - Background worker that consumes votes from Redis and stores them in PostgreSQL
* **PostgreSQL Database** - Persistent data store for vote records
* **Result Service** ([Node.js](/result)) - Web app that displays voting results in real-time

### Infrastructure Components

* **Azure Container Registry (ACR)** - Stores Docker images
* **Azure DevOps Pipelines** - CI/CD automation
* **Kubernetes Cluster** - Container orchestration platform
* **LoadBalancer Services** - External access to vote and result services

### Data Flow

```
User → Vote Service → Redis → Worker Service → PostgreSQL → Result Service → User
```

## 🐳 Docker Multi-Stage Builds

All services use **multi-stage Docker builds** for optimization:

### Example: Worker Service

```dockerfile
# Stage 1: Build (SDK image ~1GB)
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
# ... compile code ...

# Stage 2: Runtime (Runtime image ~200MB)
FROM mcr.microsoft.com/dotnet/runtime:7.0
# ... copy compiled files ...
```

**Benefits:**
- **Smaller Images**: Final image ~80% smaller than using SDK image
- **Faster Deployments**: Less data to transfer
- **Better Security**: Fewer tools and dependencies in production image
- **Cost Savings**: Reduced storage and bandwidth costs

## 🔄 Azure DevOps CI/CD Pipelines

This project implements a complete CI/CD workflow with separate pipelines for each microservice. Each pipeline follows a **3-stage deployment process**:

### Pipeline Architecture

Each service has its own pipeline (`azure-pipelines-{service}.yml`) that triggers automatically when code changes are detected in the respective service directory.

#### Pipeline Stages

1. **Build Stage**
   - Builds Docker images using **multi-stage builds** for optimization
   - Uses **Docker BuildKit** for faster, more efficient builds
   - Tags images with Azure DevOps Build ID for versioning

2. **Push Stage**
   - Pushes built images to **Azure Container Registry (ACR)**
   - Images are stored with format: `<registry>/<repository>:<build-id>`

3. **UpdateImage Stage** (GitOps-style)
   - Automatically updates Kubernetes deployment manifests
   - Commits changes back to the repository
   - Enables automatic deployment when ArgoCD or similar tools sync

### Pipeline Files

| Pipeline | Service | Repository | Trigger Path |
|----------|---------|------------|--------------|
| `azure-pipelines-vote.yml` | Python Vote App | `votingapp` | `vote/*` |
| `azure-pipelines-worker.yml` | .NET Worker | `workerapp` | `worker/*` |
| `azure-pipelines-result.yml` | Node.js Result App | `resultapp` | `result/*` |

### Key Features

- ✅ **Path-based Triggers**: Only affected services rebuild when their code changes
- ✅ **Multi-stage Docker Builds**: Optimized images (SDK → Runtime separation)
- ✅ **Docker BuildKit**: Modern build engine for better performance
- ✅ **Automated Manifest Updates**: Kubernetes YAML files updated automatically
- ✅ **GitOps Workflow**: Changes committed back to Git for tracking

### Pipeline Configuration

Each pipeline includes:
- **Container Registry**: `yuvrajcr.azurecr.io`
- **Image Tagging**: Uses `$(Build.BuildId)` for unique versioning
- **Build Optimization**: Multi-stage builds reduce final image size by ~80%

### Automated Kubernetes Manifest Updates

The `UpdateImage` stage uses a shell script (`scripts/updateK8sManifests.sh`) that:

1. Clones the repository
2. Updates the Kubernetes deployment YAML with the new image tag
3. Commits and pushes changes back to Git
4. Enables GitOps tools (like ArgoCD) to automatically sync and deploy

**Script Usage:**
```bash
./updateK8sManifests.sh <service-name> <container-registry> <image-repo> <image-tag>
```

**Example:**
```bash
./updateK8sManifests.sh vote yuvrajcr.azurecr.io votingapp 123
```

This updates `k8s-specifications/vote-deployment.yaml` with:
```yaml
image: yuvrajcr.azurecr.io/votingapp:123
```

## 🔀 GitOps Integration

This project implements **GitOps principles** similar to ArgoCD:

- **Source of Truth**: Kubernetes manifests stored in Git
- **Automated Updates**: CI/CD pipelines update manifests automatically
- **Version Control**: All deployment changes tracked in Git history
- **Sync Ready**: Compatible with ArgoCD, Flux, or similar GitOps tools

### ArgoCD Integration (Optional)

To use ArgoCD for automatic deployment:

1. Install ArgoCD in your Kubernetes cluster
2. Create an ArgoCD Application pointing to this repository:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: voting-app
   spec:
     source:
       repoURL: https://github.com/YuvrajSoam/AzureDevops-Pipeline-Project
       path: k8s-specifications
     destination:
       server: https://kubernetes.default.svc
       namespace: default
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```

3. ArgoCD will automatically sync when pipelines update the manifests

## 📋 Kubernetes Resources

### Deployments
- `vote-deployment.yaml` - Python Flask application
- `worker-deployment.yaml` - .NET background worker
- `result-deployment.yaml` - Node.js results display
- `db-deployment.yaml` - PostgreSQL database
- `redis-deployment.yaml` - Redis cache/message queue

### Services
- `vote-service.yaml` - LoadBalancer service (port 8080)
- `result-service.yaml` - LoadBalancer service (port 8081)
- `db-service.yaml` - ClusterIP service for PostgreSQL
- `redis-service.yaml` - ClusterIP service for Redis

### Features
- **LoadBalancer Services**: External access for vote and result apps
- **Image Pull Secrets**: Secure ACR authentication
- **Health Checks**: Built-in container health monitoring
- **Resource Management**: Configurable replicas and resource limits

## 🛠️ Technologies Used

- **CI/CD**: Azure DevOps Pipelines
- **Containerization**: Docker, Multi-stage builds
- **Container Registry**: Azure Container Registry (ACR)
- **Orchestration**: Kubernetes
- **GitOps**: Automated manifest updates (ArgoCD compatible)
- **Languages**: Python, .NET 7.0, Node.js
- **Databases**: PostgreSQL, Redis
- **Build Tools**: Docker BuildKit

## 📝 Notes

- The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.

- This project demonstrates modern DevOps practices including:
  - Microservices architecture
  - Containerization with Docker
  - CI/CD automation
  - GitOps workflows
  - Kubernetes deployment
  - Infrastructure as Code

## 🔗 Related Resources

- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 📄 License

This project is for educational and demonstration purposes.
