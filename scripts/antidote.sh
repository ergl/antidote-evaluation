#!/usr/bin/env bash

set -eo pipefail

REBAR_PROFILE="default"

get_ip() {
    local node_name
    node_name=$(uname -n | sed 's/$/.imdea/' | xargs dig +short)
    echo "${node_name}"
}

do_download() {
    local branch="${1}"
    local folder="${2}"
    git clone https://github.com/ergl/antidote.git --single-branch --branch "${branch}" "${folder}"
}

do_compile() {
    local folder="${1}"
    pushd "${HOME}/sources/${folder}"

    ./rebar3 as "${REBAR_PROFILE}" compile
    ./rebar3 as "${REBAR_PROFILE}" release -n antidote

    popd
}

do_run() {
    local node_ip
    local folder="${1}"

    node_ip=$(get_ip)

    pushd "${HOME}/sources/${folder}"

    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env start
    sleep 2
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env ping

    popd
}

# User supplies a config file of erlang terms, join script will parse it and
# generate node names from it
do_join() {
    local folder="${1}"
    local config_file="${2}"

    pushd "${HOME}/sources/${folder}"
    ./bin/join_cluster_script.erl "${config_file}"
    popd
}

do_flush() {
    local folder="${1}"
    local config_file="${2}"

    pushd "${HOME}/sources/${folder}"
    ./bin/flush_queues.erl "${config_file}"
    popd
}

do_restart() {
    local node_ip
    local folder="${1}"

    node_ip=$(get_ip)

    pushd "${HOME}/sources/${folder}"

    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env stop
    rm -rf _build/"${REBAR_PROFILE}"/rel
    ./rebar3 as "${REBAR_PROFILE}" release -n antidote
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env start
    sleep 2
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env ping

    popd
}

do_rebuild() {
    local node_ip
    local branch="${1}"
    local folder="${2}"

    node_ip=$(get_ip)

    pushd "${HOME}/sources/${folder}"
    rm -rf _build/"${REBAR_PROFILE}"/

    git fetch origin
    git reset --hard origin/"${branch}"

    ./rebar3 as "${REBAR_PROFILE}" compile
    ./rebar3 as "${REBAR_PROFILE}" release -n antidote
    popd
}

do_start() {
    local node_ip
    local folder="${1}"

    node_ip=$(get_ip)

    pushd "${HOME}/sources/${folder}"
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env start
    sleep 2
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env ping
    popd
}

do_stop() {
    local node_ip
    local folder="${1}"

    node_ip=$(get_ip)

    pushd "${HOME}/sources/${folder}"
    IP="${node_ip}" ./_build/"${REBAR_PROFILE}"/rel/antidote/bin/env stop
    popd
}

do_ring_change() {
    local folder="${1}"
    local size="${2}"

    pushd "${HOME}/sources/${folder}"
    sed -i "s|.*ring_creation_size.*|-riak_core ring_creation_size ${size}|g" config/vm.args
    grep ring_creation_size config/vm.args
    popd
}

do_vlog_version_change() {
    local folder="${1}"
    local upper_size="${2}"
    local lower_size=$((upper_size / 2))

    pushd "${HOME}/sources/${folder}"
    sed -i "s|.*(GC_THRESHOLD.*|-define(GC_THRESHOLD, ${upper_size}).|g" src/pvc_version_log.erl
    sed -i "s|.*(KEEP_VERSIONS.*|-define(KEEP_VERSIONS, ${lower_size}).|g" src/pvc_version_log.erl
    popd
}

do_clog_version_change() {
    local folder="${1}"
    local upper_size="${2}"
    local lower_size=$((upper_size / 2))

    pushd "${HOME}/sources/${folder}"
    sed -i "s|.*(GC_THRESHOLD.*|-define(GC_THRESHOLD, ${upper_size}).|g" src/pvc_commit_log.erl
    sed -i "s|.*(KEEP_VERSIONS.*|-define(KEEP_VERSIONS, ${lower_size}).|g" src/pvc_commit_log.erl
    popd
}

usage() {
    echo -e "antidote.sh [-h] [-d] [-b <branch>=pvc] <command>
Commands:
dl <folder>=branch\tDownloads antidote with the selected branch to the given folder.
\t\t\tDefault is the given branch name in the local folder.
compile
join <config> \tJoins the nodes listed in the config file
flush <config> \tFlushes the commit queues of the nodes listed in the config file
start
stop
restart \tReboots Antidote, cleaning the release
rebuild \tRecompiles Antidote from a fresh copy of the repo
ring <number> \tChanges the ring size to the given number.
vlog_versions <number> \tChanges the upper key version size to the given number.
clog_versions <number> \tChanges the upper commit version size to the given number.
"
}

run() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local branch="pvc"
    while getopts ":b:dh" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            b)
                branch="${OPTARG}"
                ;;
            d)
                REBAR_PROFILE="debug_log"
                ;;
            :)
                echo "Option -${OPTARG} requires an argument"
                usage
                exit 1
                ;;
            *)
                echo "Unrecognized option -${OPTARG}"
                usage
                exit 1
                ;;
        esac
    done

        shift $((OPTIND - 1))

    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    local command="${1}"
    case $command in
        "dl")
            local dl_target="${2:-"sources/${branch}"}"
            do_download "${branch}" "${dl_target}"
            exit $?
            ;;

        "compile")
            do_compile "${branch}"
            exit $?
            ;;

        "run")
            do_run "${branch}"
            exit $?
            ;;

        "join")
            if [[ $# -lt 2 ]]; then
                usage
                exit 1
            fi

            local node_file_path="${2}"
            do_join "${branch}" "${node_file_path}"
            exit $?
            ;;

        "flush")
            if [[ $# -lt 2 ]]; then
                usage
                exit 1
            fi

            local node_file_path="${2}"
            do_flush "${branch}" "${node_file_path}"
            exit $?
            ;;

        "restart")
            do_restart "${branch}"
            exit $?
            ;;

        "start")
            do_start "${branch}"
            exit $?
            ;;

        "stop")
            do_stop "${branch}"
            exit $?
            ;;

        "rebuild")
            do_rebuild "${branch}" "${branch}"
            exit $?
            ;;

        "ring")
            local ring_size="${2:-32}"
            echo -e "Changing ring size to ${ring_size}"
            do_ring_change "${branch}" "${ring_size}"
            exit $?
            ;;

        "vlog_versions")
            if [[ $# -ne 2 ]]; then
                echo -e "Needs a value!"
                exit 1
            fi

            local upper_vsn="${2}"
            echo -e "Changing key versions to ${upper_vsn}"
            do_vlog_version_change "${branch}" "${upper_vsn}"
            exit $?
            ;;

        "clog_versions")
            if [[ $# -ne 2 ]]; then
                echo -e "Needs a value!"
                exit 1
            fi

            local upper_vsn="${2}"
            echo -e "Changing commit versions to ${upper_vsn}"
            do_clog_version_change "${branch}" "${upper_vsn}"
            exit $?
            ;;

        *)
            echo "Unrecognized command ${command}"
            usage
            exit 1
            ;;
    esac
}

run "$@"
