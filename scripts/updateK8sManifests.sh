#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./updateK8sManifests.sh <service-name> <container-registry> <image-repo> <image-tag>
# Example:
# ./updateK8sManifests.sh vote yuvrajcr.azurecr.io votingapp 123

SERVICE_NAME="$1"
CONTAINER_REGISTRY="$2"
IMAGE_REPO="$3"
IMAGE_TAG="$4"

# Construct full image path: <registry>/<repo>:<tag>
# Note: ACR repository name doesn't include service name, just the repo name
FULL_IMAGE_PATH="${CONTAINER_REGISTRY}/${IMAGE_REPO}:${IMAGE_TAG}"

REPO_URL="<PAT token for azure devops repo>@dev.azure.com/YuvrajSoam/voting-app/_git/voting-app"
TEMP_DIR="/tmp/temp_repo"

echo "Cloning repository..."
git clone "$REPO_URL" "$TEMP_DIR"

cd "$TEMP_DIR"

# Checkout main branch (avoid detached HEAD)
git checkout main

DEPLOYMENT_FILE="k8s-specifications/${SERVICE_NAME}-deployment.yaml"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
  echo "ERROR: Deployment file not found: $DEPLOYMENT_FILE"
  exit 1
fi

echo "Updating image in $DEPLOYMENT_FILE to $FULL_IMAGE_PATH"
sed -i "s|image:.*|image: ${FULL_IMAGE_PATH}|g" "$DEPLOYMENT_FILE"

git add "$DEPLOYMENT_FILE"

git commit -m "Update ${SERVICE_NAME} image to ${FULL_IMAGE_PATH}"

git push

echo "Cleanup..."
rm -rf "$TEMP_DIR"

echo "Done ✅"
