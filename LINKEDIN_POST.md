# LinkedIn Post - Azure DevOps CI/CD with Kubernetes Deployment

---

**End-to-End CI/CD Pipeline with Azure DevOps & Azure Kubernetes Service (AKS) 🚀**

Thrilled to share my latest project where I built a complete CI/CD pipeline for a microservices voting application deployed on Azure Kubernetes Service! Here's what I accomplished:

✅ **Multi-Service Architecture** – Deployed a distributed voting app with Python (Flask), .NET worker, and Node.js services, along with Redis and PostgreSQL.

✅ **Azure DevOps CI/CD Pipelines** – Created separate pipelines for each microservice with path-based triggers, ensuring only affected services rebuild when code changes.

✅ **Optimized Docker Builds** – Implemented multi-stage Docker builds using BuildKit, reducing final image size by ~80% (from ~1GB SDK to ~200MB runtime images).

✅ **Azure Container Registry (ACR)** – Automated image builds and pushes to ACR with versioned tags using Azure DevOps Build IDs.

✅ **Kubernetes Deployment on AKS** – Deployed all services to Azure Kubernetes Service with proper resource management, health checks, and image pull secrets.

✅ **LoadBalancer Services** – Configured Azure LoadBalancer services for external access to vote and result applications (though Ingress can be used for more advanced routing).

✅ **GitOps with ArgoCD** – Implemented ArgoCD for continuous deployment, automatically syncing Kubernetes manifests from Git to AKS cluster. The CI/CD pipeline updates manifests after each build, and ArgoCD detects changes and deploys them automatically.

✅ **Automated Manifest Updates** – Built a custom script that updates Kubernetes deployment YAML files with new image tags after each build and commits changes back to Git, creating a GitOps workflow where Git is the single source of truth.

✅ **Persistent Storage** – Configured Persistent Volumes for PostgreSQL to ensure data persistence across pod restarts.

✅ **Secrets Management** – Secured ACR credentials using Kubernetes Secrets for secure image pulls.

This project gave me hands-on experience with:
- Azure DevOps pipeline automation
- Multi-stage Docker builds and optimization
- Kubernetes orchestration on Azure AKS
- **ArgoCD GitOps workflows** and continuous deployment
- Automated manifest management and synchronization
- Microservices architecture patterns

**Future Enhancements I'm Planning:**
🔹 Replace LoadBalancer with **Ingress** for more efficient routing and SSL termination
🔹 Integrate **ArgoCD Image Updater** for automatic image updates without manual manifest changes
🔹 Implement **Helm** or **Kustomize** for environment-specific configurations (dev/staging/prod)
🔹 Add monitoring and observability with Azure Monitor and Prometheus

The entire workflow is now fully automated: code commit → Azure DevOps builds → push to ACR → update K8s manifests in Git → **ArgoCD syncs and deploys to AKS**. Zero manual intervention! 🎯

Would love to hear feedback and insights from the DevOps community!

#AzureDevOps #Kubernetes #Docker #CI/CD #AzureAKS #DevOps #GitOps #ArgoCD #Microservices #CloudNative #Containerization #AzureCloud #InfrastructureAsCode

---
