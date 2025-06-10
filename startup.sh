#!/bin/bash

podman pull docker.all-hands.dev/all-hands-ai/runtime:0.41-nikolaik

EXTRA_PODMAN_OPTS=()

# Check if we're using Podman
if command -v podman &> /dev/null && [ -z "$USE_DOCKER" ]; then
  echo "INFO: Detected Podman installation"

  # Start Podman API service if not already running
  echo "INFO: Starting Podman API service..."
  podman system service --time=0 tcp://127.0.0.1:8888 &
  PODMAN_API_PID=$!

  # Give the API service time to start
  sleep 2

  # Set DOCKER_HOST to use the TCP API
  EXTRA_PODMAN_OPTS+=("-e" "DOCKER_HOST=tcp://host.containers.internal:8888")
  echo "INFO: Set DOCKER_HOST to tcp://host.containers.internal:8888 for Podman API access"

  # Add host.containers.internal mapping for macOS
  EXTRA_PODMAN_OPTS+=("--add-host" "host.containers.internal:host-gateway")
else
  echo "INFO: Using Docker or USE_DOCKER is set"
fi

podman run -it --rm --pull=always \
    "${EXTRA_PODMAN_OPTS[@]}" \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.41-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -e SANDBOX_VOLUMES=/Users/mfischer/Development/OpenHands:/workspace:rw \
    -v ~/.openhands-state:/.openhands-state \
    -p 3000:3000 \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.41

# Clean up Podman API service on exit
if [ -n "$PODMAN_API_PID" ]; then
  echo "INFO: Stopping Podman API service..."
  kill $PODMAN_API_PID 2>/dev/null || true
fi
