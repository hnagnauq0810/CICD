#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_REF="${1:-${IMAGE_REF:-}}"
DEPLOY_ENVIRONMENT="${2:-${DEPLOY_ENVIRONMENT:-staging}}"
PORT="${PORT:-8000}"
CONTAINER_NAME="${CONTAINER_NAME:-cicd-pipeline-demo-${DEPLOY_ENVIRONMENT}}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:${PORT}/health}"

if [[ -z "${IMAGE_REF}" ]]; then
  echo "ERROR: IMAGE_REF is required."
  echo "Usage: ./deploy.sh ghcr.io/owner/repo:image-tag staging"
  exit 1
fi

on_error() {
  echo "Deployment failed for environment: ${DEPLOY_ENVIRONMENT}"
  docker logs --tail 100 "${CONTAINER_NAME}" 2>/dev/null || true
}
trap on_error ERR

echo "Deploying ${IMAGE_REF} to ${DEPLOY_ENVIRONMENT}"
echo "Container name: ${CONTAINER_NAME}"
echo "Health URL: ${HEALTH_URL}"

docker pull "${IMAGE_REF}"
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

docker run   --detach   --name "${CONTAINER_NAME}"   --publish "${PORT}:8000"   --restart unless-stopped   "${IMAGE_REF}"

echo "Waiting for application health check..."
for attempt in {1..30}; do
  if curl --fail --silent --show-error "${HEALTH_URL}" >/tmp/health-response.json; then
    echo "Health check passed on attempt ${attempt}."
    cat /tmp/health-response.json
    echo
    echo "Deployment succeeded for environment: ${DEPLOY_ENVIRONMENT}"
    exit 0
  fi

  echo "Health check attempt ${attempt}/30 failed. Retrying in 2 seconds..."
  sleep 2
done

echo "Health check failed after 30 attempts."
exit 1
