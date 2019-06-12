#!/bin/bash
# Docker instructions to build and push the image
set -e
# Uncomment next line and put your registry in
#export DOCKER_REGISTRY="acrreplace.azurecr.io/reporeplace/"
export DOCKER_REGISTRY=brusmx
export TAG="1.0"
export IMAGE="${DOCKER_REGISTRY}/postgresql-python-sample:$TAG"
export IMAGE_PLACEHOLDER="acrreplace.azurecr.io/reporeplace/imagereplace:replacetag"
echo "Building and deploying $IMAGE"
[ -z "$DOCKER_REGISTRY" ] && echo "Error: \$DOCKER_REGISTRY must be specified." && exit 1
docker build -t $IMAGE .
docker push $IMAGE

echo "Image has been pushed as:"
echo "$IMAGE"

echo "Updating yaml file..."
cp deployment-logger-base.yaml deployment-logger-$TAG.yaml
sed -i '' "s@$IMAGE_PLACEHOLDER@$IMAGE@g" deployment-logger-$TAG.yaml
echo "Updated. Get your deployment working on the cluster:"
echo "kubectl apply -f deployment-logger-$TAG.yaml"