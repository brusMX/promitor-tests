#!/bin/bash
# Docker instructions to build and push the image
set -e
# Uncomment next line and put your registry in
#export DOCKER_REGISTRY="brusmx"
export TAG="1.0"
export IMAGE="${DOCKER_REGISTRY}/redis-ruby-sample:$TAG"
export IMAGE_PLACEHOLDER="brusmx/redis-ruby-sample:1.0"
echo "Building and deploying $IMAGE"
[ -z "$DOCKER_REGISTRY" ] && echo "Error: \$DOCKER_REGISTRY must be specified." && exit 1
cd Blog
docker build -t $IMAGE .
docker push $IMAGE

echo "Image has been pushed as:"
echo "$IMAGE"

echo "Updating yaml file..."
cd ..
sed -i '' "s@$IMAGE_PLACEHOLDER@$IMAGE@g" redis-ruby-deployment.yaml
echo "Updated. Get your deployment working on the cluster:"
echo "kubectl apply -f redis-ruby-deployment.yaml"