#!/bin/bash
# Common functions and variables for the scripts
set -e # Exit on error
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/script.log"
exec > >(tee -a "$LOG_FILE") 2>&1
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"
log() {
    local message="$1"
    echo "$(date "$DATE_FORMAT") - $message"
}
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log "Error: Command '$cmd' not found."
        exit 1
    fi
}
}# Example usage of check_command
check_command "bash"
log "All required commands are available." 
# End of 01-common.sh