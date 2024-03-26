#!/usr/bin/env bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Runs basic lifecycle E2E tests against kn func cli for a given language/runtime.
# By default it will run e2e tests against 'func' binary, but you can change it to use 'kn func' instead
#
# The following environment variable can be set in order to customize e2e execution:
#
# E2E_USE_KN_FUNC    When set to "true" indicates e2e to issue func command using kn cli.
#
# E2E_REGISTRY_URL   Indicates a specific registry (i.e: "quay.io/user") should be used. Make sure
#                    to authenticate to the registry (i.e: docker login ...) prior to execute the script
#                    By default it uses "ttl.sh" registry
#
# E2E_FUNC_BIN_PATH  Path to func binary. Derived by this script when not set
#
# E2E_RUNTIMES       List of runtimes (space separated) to execute TestRuntime.
#

set -o errexit
set -o nounset
set -o pipefail

pushd "$(dirname "$0")/.."

export E2E_REGISTRY_URL="${E2E_REGISTRY_URL:-default}"
export E2E_FUNC_BIN_PATH="${E2E_FUNC_BIN_PATH:-$(pwd)/func}"
export E2E_USE_KN_FUNC="false"

# Ensure 'func' binary is built
if [[ ! -f "$E2E_FUNC_BIN_PATH" ]]; then
  echo "building func binary"
  make build
fi

# Deploy GitServer
oc adm policy add-scc-to-user anyuid -z default
./test/gitserver.sh

# Execute on cluster tests
go test -v -test.v -test.timeout=90m -tags="oncluster" ./test/oncluster/
ret=$?

popd
exit $ret
