#!/bin/bash
# Docker instructions to build and push the image
set -e
# Uncomment next line and put your docker hub username in it
#export DOCKER_REGISTRY="brusmx"
export TAG="1.0"
export IMAGE="${DOCKER_REGISTRY}/postgresql-python-sample:$TAG"
export IMAGE_PLACEHOLDER="brusmx/postgresql-python-sample:1.0"
echo "Building and deploying $IMAGE"
[ -z "$DOCKER_REGISTRY" ] && echo "Error: \$DOCKER_REGISTRY must be specified." && exit 1
docker build -t $IMAGE .
docker push $IMAGE

echo "Image has been pushed as:"
echo "$IMAGE"

echo "Updating yaml file. Pointing to new image"
sed -i '' "s@$IMAGE_PLACEHOLDER@$IMAGE@g" postgresql-python-deployment.yaml
echo "Updated. Get your deployment working on the cluster:"
echo "kubectl apply -f postgresql-python-deployment.yaml"