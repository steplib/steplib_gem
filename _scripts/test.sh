#!/bin/bash

set -v
set -e


THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${THIS_SCRIPT_DIR}/.."

bundle exec rspec

echo "==> DONE"
