#!/usr/bin/env bash
#
# Setup Test Git Server used by On Cluster Tests
#

set -o errexit
set -o nounset
set -o pipefail

GITSERVER_IMAGE="${GITSERVER_IMAGE:-ghcr.io/jrangelramos/gitserver-unpriv:latest}"

go env
source "$(go run knative.dev/hack/cmd/script e2e-tests.sh)"

BASEDIR=$(dirname "$0")

header "Installing Test GitServer"
sed "s!_GITSERVER_IMAGE_!${GITSERVER_IMAGE}!g" "${BASEDIR}/deploy/gitserver-service.yaml" > "${BASEDIR}/deploy/gitserver.yaml"
oc apply -f "${BASEDIR}/deploy/gitserver.yaml"
oc wait pod/gitserver --for=condition=Ready --timeout=15s

subheader "Exposing Test GitServer route"
oc expose service gitserver --name=gitserver --port=8080

success
