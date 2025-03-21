#!/usr/bin/bash

: '
    Double SHA256
    Generate a random 32-byte hex string and hash it twice using SHA256
'
STRING_LOCK_NAME=".bash_hashing.lock"
STRING_LOCK_NAME_SERVER=".server_hashing.lock"
export STRING_LOCK_NAME_SERVER

: '
    Check if lock file exists
    If not, create it and store the double SHA256 hash
'
if [ ! -f "$STRING_LOCK_NAME" ]; then
    : ' Create Lock File '
    touch "$STRING_LOCK_NAME"
    echo "$BASH_DOUBLE_SHA256" > "$STRING_LOCK_NAME"
    : ' Execute with SHA256 '
    exec -a "$BASH_DOUBLE_SHA256" ./"$BASH_NAME"
fi

: '
    Cleanup function
    Removes temporary files and terminates the process if needed
'

security_file_rm()
{
    : ' Remove File Logs '
    cd "$BASH_DIR" >/dev/null 2>&1 || echo "" &&
    ignore_this rm ".cache"

    if [ -f "$LOG_SERVER" ]; then
        ignore_this rm "$LOG_SERVER"
    fi
}

security_cleanup() {
    security_file_rm ""
    
    if [ -f "$STRING_LOCK_NAME" ]; then
        # Find PID From "STRING_LOCK_NAME" >>> file: ".bash_hashing.lock"
        PID=$(cat "$STRING_LOCK_NAME")
        # Kill All PID
        ignore_this kill -9 "$PID"
        # Delete the PID file
        rm "$STRING_LOCK_NAME"
    fi

    wait && exit
}

: '
    @cleanup
    Trap cleanup function for termination signals

    @list security_cleanup
        SIGINT: Signal Interrupt
        SIGTERM: Signal Terminate
        SIGQUIT: Signal Quit
        SIGHUP: Signal Hangup
'
trap security_cleanup SIGINT SIGTERM SIGQUIT SIGHUP
