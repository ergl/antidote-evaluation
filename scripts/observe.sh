#!/usr/bin/env bash

set -eo pipefail

run() {
    local node_name="${1:-"apollo-1-1.imdea"}"
    local node_ip=$(dig +short "${node_name}")
    erl -name health@127.0.0.1 -setcookie antidote -eval "net_kernel:connect_node('antidote@${node_ip}')" -run observer
}

run "$@"
