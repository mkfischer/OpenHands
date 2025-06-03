#!/bin/bash

podman pull docker.all-hands.dev/all-hands-ai/runtime:0.40-nikolaik

EXTRA_PODMAN_OPTS=()

if [ -n "$PODMAN_SOCKET_PATH" ]; then
  echo "INFO: PODMAN_SOCKET_PATH is set: $PODMAN_SOCKET_PATH"
  HOST_SOCK_PATH="${PODMAN_SOCKET_PATH#unix://}"

  # Check if the host socket path exists and is a socket
  if [ ! -S "$HOST_SOCK_PATH" ]; then
    echo "WARNING: Podman socket path '$HOST_SOCK_PATH' on the host does not exist or is not a socket."
    echo "Please ensure PODMAN_SOCKET_PATH is set correctly to your Podman socket (e.g., from 'podman machine inspect') and the Podman service/machine is running."
    # Depending on the system, it might be a different type of file, but for macOS/Linux VM, it's typically a socket.
  fi

  EXTRA_PODMAN_OPTS+=("-v" "$HOST_SOCK_PATH:/var/run/docker.sock:z")
  EXTRA_PODMAN_OPTS+=("-e" "DOCKER_HOST=unix:///var/run/docker.sock")
  echo "INFO: Added Podman socket volume mount and DOCKER_HOST=unix:///var/run/docker.sock environment variable for the container."
else
  echo "INFO: PODMAN_SOCKET_PATH is not set. Assuming a standard Docker environment where DOCKER_HOST might be inherited or the default socket is used."
  # If you are using Docker on Linux and need to explicitly mount the Docker socket:
  # if [ -S /var/run/docker.sock ]; then
  #   EXTRA_PODMAN_OPTS+=("-v" "/var/run/docker.sock:/var/run/docker.sock:z")
  #   # Optionally, ensure DOCKER_HOST is set if not already, though docker.from_env() should find it.
  #   # EXTRA_PODMAN_OPTS+=("-e" "DOCKER_HOST=unix:///var/run/docker.sock")
  # fi
fi

podman run -it --rm --pull=always \
    "${EXTRA_PODMAN_OPTS[@]}" \
    --user root \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.40-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -e SANDBOX_VOLUMES=/Users/mfischer/Development/OpenHands:/workspace:rw \
    -v ~/.openhands-state:/.openhands-state \
    -p 3000:3000 \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.40
