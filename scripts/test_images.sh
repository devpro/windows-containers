#!/usr/bin/env bash
# Builds the sample images on the Windows engine, runs each one and checks it answers, then removes the container.
# Usage: scripts/test_images.sh [image-name...], every image when none is named.
# Runs from WSL, or Git Bash on Windows, with Docker CE on Windows reached through the "win" context.

set -euo pipefail

# The Windows engine is always named, so that a Docker engine running in WSL is never used by mistake.
docker_win() {
  docker.exe --context win "$@"
}

# name|build context|image definition|host port|container port|paths answering 200
IMAGES=(
  "winsamplenet48mvcwebapp|samples/dotnet-4.8|SampleMvcWebApp/Dockerfile|8081|80|/ /Home/About /Home/Contact"
  "winsamplenet48svc|samples/dotnet-4.8|SampleWindowsService/Dockerfile|||"
  "winsamplenet10razorwebapp|samples/dotnet-10.0|src/SampleRazorWebApp/Dockerfile|8080|8080|/ /Privacy"
)

# A Windows container takes up to a few minutes to report healthy, Server Core and IIS being the slowest.
HEALTH_TIMEOUT_SECONDS=300

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
container=""

cleanup() {
  if [ -n "$container" ]; then
    docker_win rm --force "$container" > /dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

wait_healthy() {
  local name=$1 waited=0 status
  while [ "$waited" -lt "$HEALTH_TIMEOUT_SECONDS" ]; do
    status=$(docker_win inspect --format '{{.State.Status}} {{.State.Health.Status}}' "$name" | tr -d '\r')
    case "$status" in
      "running healthy") return 0 ;;
      "running unhealthy") echo "ERROR: $name is unhealthy" >&2; return 1 ;;
      running*) ;;
      *) echo "ERROR: $name is $status" >&2; return 1 ;;
    esac
    sleep 5
    waited=$((waited + 5))
  done
  echo "ERROR: $name not healthy after ${HEALTH_TIMEOUT_SECONDS}s" >&2
  return 1
}

test_image() {
  local name=$1 context=$2 definition=$3 host_port=$4 container_port=$5 paths=$6
  # Called from a condition, where errexit does not apply, so every step that can fail returns on its own.
  local tag="${name}:local" code path publish=()

  echo "=== ${name}: build"
  # The Windows engine has no BuildKit, and the classic builder is asked for so that no warning says it is missing.
  (cd "${root}/${context}" && DOCKER_BUILDKIT=0 docker_win build --file "$definition" --tag "$tag" .) || return 1

  echo "=== ${name}: run"
  container="test-${name}"
  docker_win rm --force "$container" > /dev/null 2>&1 || true
  if [ -n "$host_port" ]; then
    publish=(--publish "${host_port}:${container_port}")
  fi
  docker_win run --detach --name "$container" "${publish[@]}" "$tag" > /dev/null || return 1

  if ! wait_healthy "$container"; then
    docker_win logs "$container" || true
    return 1
  fi
  echo "${name} is healthy"

  for path in $paths; do
    # The port is published on the Windows host, which curl.exe reaches whatever the WSL networking mode.
    code=$(curl.exe --silent --output NUL --write-out '%{http_code}' --max-time 30 "http://localhost:${host_port}${path}" | tr -d '\r')
    echo "GET ${path} -> ${code}"
    if [ "$code" != "200" ]; then
      docker_win logs "$container" || true
      return 1
    fi
  done

  docker_win rm --force "$container" > /dev/null
  container=""
}

selected=("$@")
failed=()
for entry in "${IMAGES[@]}"; do
  IFS='|' read -r name context definition host_port container_port paths <<< "$entry"
  if [ "${#selected[@]}" -gt 0 ] && [[ ! " ${selected[*]} " == *" ${name} "* ]]; then
    continue
  fi
  if ! test_image "$name" "$context" "$definition" "$host_port" "$container_port" "$paths"; then
    failed+=("$name")
    cleanup
    container=""
  fi
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILED: ${failed[*]}" >&2
  exit 1
fi
echo "All images passed"
