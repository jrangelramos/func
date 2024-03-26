#!/usr/bin/env bash
#
# Setup Openshift Serverless and Pipelines
#

set -o errexit
set -o nounset
set -o pipefail

go env
source "$(go run knative.dev/hack/cmd/script e2e-tests.sh)"

BASEDIR=$(dirname "$0")

# Installs openshift Serverless
header "Installing Openshift Serverless"
kubectl apply -f ${BASEDIR}/deploy/serverless-subscription.yaml
wait_until_pods_running openshift-serverless

subheader "Installing Serving and Eventing"
kubectl apply -f ${BASEDIR}/deploy/knative-serving.yaml
kubectl apply -f ${BASEDIR}/deploy/knative-eventing.yaml
kubectl wait --for=condition=Ready --timeout=5m knativeserving knative-serving -n knative-serving
kubectl wait --for=condition=Ready --timeout=5m knativeeventing knative-eventing -n knative-eventing

# Installs Openshift Pipelines
header "Installing Openshift Pipelines"
kubectl apply -f ${BASEDIR}/deploy/pipelines-subscription.yaml
wait_until_pods_running openshift-pipelines

success
