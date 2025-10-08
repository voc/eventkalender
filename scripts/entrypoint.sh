#!/bin/sh

PATH="$PATH:$(gem environment user_gemhome)/bin"

set -e

json_log () {
    MESSAGE=${1?}
    echo "{\"@type\":\"startup-logs\",\"message\":\"${MESSAGE}\"}"
}

json_log "finished: $0"

exec "${@}"
