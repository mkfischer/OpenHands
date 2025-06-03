podman pull docker.all-hands.dev/all-hands-ai/runtime:0.40-nikolaik

podman run -it --rm --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.40-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v "$PODMAN_SOCKET_PATH":/var/run/docker.sock:z \
    -v ~/.openhands-state:/.openhands-state \
    -p 3000:3000 \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.40
