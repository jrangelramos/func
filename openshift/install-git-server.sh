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

header "Installing Test GitServer"

cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: gitserver
  name: gitserver
spec:
  containers:
  - image: ${GITSERVER_IMAGE}
    name: user-container
    ports:
      - containerPort: 8080
EOF
oc wait pod/gitserver --for=condition=Ready --timeout=15s


cat << EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: gitserver
spec:
  type: NodePort
  selector:
    app: gitserver
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF

subheader "Exposing Test GitServer route"
oc expose service gitserver --name=gitserver --port=8080

success
