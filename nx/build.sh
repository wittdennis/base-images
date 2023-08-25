#!/bin/bash

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

CONTAINER_CMD="docker"
if [ -x "$(command -v podman)" ]; then
    CONTAINER_CMD=$(command -v podman)
fi

CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-"localhost:5000"}
NX_VERSION=${NX_VERSION:-"16.7.4"}
PNPM_VERSION=${PNPM_VERSION:-"8.6.12"}
YARN_VERSION=${YARN_VERSION:-"3.6.3"}
NODE_IMAGE=${NODE_IMAGE:-"node:18.17.1-bookworm"}
IMAGE_NAME=${IMAGE_NAME:-"nx"}

REPOSITORY="$CONTAINER_REGISTRY/$IMAGE_NAME"
TAG="$NX_VERSION-$(echo $NODE_IMAGE | sed 's|:|-|g')"
MANIFEST="$REPOSITORY:$TAG"
PLATFORMS=("linux/arm/v7" "linux/arm/")

function cleanup_manifest {
    $CONTAINER_CMD manifest rm $MANIFEST
}
trap cleanup_manifest EXIT

$CONTAINER_CMD manifest create $MANIFEST

for PLATFORM in ${PLATFORMS[@]}; do
    PLATFORM_TAG=$(echo $PLATFORM | sed 's|/|-|g')
    IMAGE="$REPOSITORY:$TAG-$PLATFORM_TAG"

    $CONTAINER_CMD build \
            --build-arg NX_VERSION=$NX_VERSION \
            --build-arg PNPM_VERSION=$PNPM_VERSION \
            --build-arg YARN_VERSION=$YARN_VERSION \
            --build-arg NODE_IMAGE=$NODE_IMAGE \
            --manifest $MANIFEST \
            --platform $PLATFORM -t $IMAGE -f "$SCRIPT_PATH/Dockerfile" "$SCRIPT_PATH"    
    $CONTAINER_CMD push $IMAGE
done

$CONTAINER_CMD manifest push --all $MANIFEST