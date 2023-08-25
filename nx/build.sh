#!/bin/bash

set -e

function join {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

CONTAINER_CMD="docker"
if [ -x "$(command -v podman)" ]; then
    CONTAINER_CMD=$(command -v podman)
fi
echo "Using $CONTAINER_CMD as container runtime"
echo $CONTAINER_CMD version

CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-"localhost:5000"}
NX_VERSION=${NX_VERSION:-"16.7.4"}
PNPM_VERSION=${PNPM_VERSION:-"8.6.12"}
YARN_VERSION=${YARN_VERSION:-"3.6.3"}
NODE_IMAGE=${NODE_IMAGE:-"node:18.17.1-bookworm"}
IMAGE_NAME=${IMAGE_NAME:-"nx"}

REPOSITORY="$CONTAINER_REGISTRY/$IMAGE_NAME"
TAG="$NX_VERSION-$(echo $NODE_IMAGE | sed 's|:|-|g')"
MANIFEST="$REPOSITORY:$TAG"
PLATFORMS=("linux/amd64")

IMAGES=()
for PLATFORM in ${PLATFORMS[@]}; do    
    PLATFORM_TAG=$(echo $PLATFORM | sed 's|/|-|g')
    IMAGE="$REPOSITORY:$TAG-$PLATFORM_TAG"
    IMAGES+=($IMAGE)
    echo "Building image for platform $PLATFORM using platform tag: $PLATFORM_TAG"

    $CONTAINER_CMD build \
            --build-arg NX_VERSION=$NX_VERSION \
            --build-arg PNPM_VERSION=$PNPM_VERSION \
            --build-arg YARN_VERSION=$YARN_VERSION \
            --build-arg NODE_IMAGE=$NODE_IMAGE \
            --platform "$PLATFORM" -t "$IMAGE" -f "$SCRIPT_PATH/Dockerfile" "$SCRIPT_PATH"    
    $CONTAINER_CMD push "$IMAGE"
done

MANIFEST_AMENDS=$(join ' --amends ' ${IMAGES[@]})
$CONTAINER_CMD manifest rm "$MANIFEST" 2> /dev/null || true
$CONTAINER_CMD manifest create "$MANIFEST" --amend $MANIFEST_AMENDS

if [[ $CONTAINER_CMD == *"podman"* ]]; then
    # this is only needed because the github runner ubuntu-22.04 does not have a podman version with PR: https://github.com/containers/podman/pull/18395
    $CONTAINER_CMD manifest push "$MANIFEST" "docker://$MANIFEST"
else
    $CONTAINER_CMD manifest push "$MANIFEST"
fi