# #!/bin/bash

# set -x

# # Set the repository URL
# REPO_URL="https://EbSfYJNAn2OpfUJ0QdYVYxTlD4Huz3bBGGcZmPFtDmzgriFhLV7oJQQJ99CAACAAAAA5TuKfAAASAZDO2K7m@dev.azure.com/YuvrajSoam/voting-app/_git/voting-app"

# # Clone the git repository into the /tmp directory
# git clone "$REPO_URL" /tmp/temp_repo

# # Navigate into the cloned repository directory
# cd /tmp/temp_repo

# # Make changes to the Kubernetes manifest file(s)
# # For example, let's say you want to change the image tag in a deployment.yaml file
# sed -i "s|image:.*|image: yuvrajcr/$2:$3|g" k8s-specifications/$1-deployment.yaml

# # Add the modified files
# git add .

# # Commit the changes
# git commit -m "Update Kubernetes manifest"

# # Push the changes back to the repository
# git push

# # Cleanup: remove the temporary directory
# rm -rf /tmp/temp_repo

#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./updateK8sManifests.sh <service-name> <image-repo> <image-tag>
# Example:
# ./updateK8sManifests.sh vote yuvrajcr vote-123

SERVICE_NAME="$1"
IMAGE_REPO="$2"
IMAGE_TAG="$3"

REPO_URL="https://EbSfYJNAn2OpfUJ0QdYVYxTlD4Huz3bBGGcZmPFtDmzgriFhLV7oJQQJ99CAACAAAAA5TuKfAAASAZDO2K7m@dev.azure.com/YuvrajSoam/voting-app/_git/voting-app"
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

echo "Updating image in $DEPLOYMENT_FILE"
sed -i "s|image:.*|image: ${IMAGE_REPO}/${SERVICE_NAME}:${IMAGE_TAG}|g" "$DEPLOYMENT_FILE"

git add "$DEPLOYMENT_FILE"

git commit -m "Update ${SERVICE_NAME} image to ${IMAGE_TAG}"

git push

echo "Cleanup..."
rm -rf "$TEMP_DIR"

echo "Done ✅"
