#!/usr/bin/bash

check_os() {
    : '
        Compat for Windows, Linux & MacOS, and detect OMP/SAMP server.
    '

    if [ "$_OS_ACCEPT" != 1 ]; then
        OS_TYPE=$(uname)

        if [[ "$OS_TYPE" == "Linux" ]]; then
            cat /etc/os-release &>/dev/null
            _OS_GNU_LINUX=1
            _OS_PAWNCC="pawncc"
            _OS_DISABLE_GNU_NANO="false"
        elif [[ "$OS_TYPE" == "Darwin" ]]; then
            _OS_DARWIN=1
            _OS_PAWNCC="pawncc"
            _OS_DISABLE_GNU_NANO="true"

            if ! command -v docker &>/dev/null; then
                echo -e "$(bash_coltext_r "crit:") Docker not found!.."
                echo "Install first!. See: https://github.com/vilksons/triops/wiki/Get-Started"
            fi
        elif [ -d "/c/Windows/System32" ] || [ -d "/mnt/c/Windows/System32" ] || [ -d "/Windows/System32" ]; then
            _OS_WINDOWS=1
            _OS_PAWNCC="pawncc.exe"
            _OS_DISABLE_GNU_NANO="true"
        fi

        if { [ "$_OS_WINDOWS" == 1 ] && [ "$_OS_GNU_LINUX" == 1 ]; } || 
           [ "$_OS_DARWIN" == 1 ] || 
           { [ "$_OS_GNU_LINUX" == 1 ] && [ "$_OS_DARWIN" == 1 ]; }; then
            
            echo -e "$(bash_coltext_a ":: System detected both Windows and Linux / MacOS (Darwin). Which one will you choose?")"
            read -r -p "Choose OS for Triops Y) Windows, B) GNU/Linux, X) Darwin (Mac): " PERMISSION_NEED_OS

            while true; do
                case "$PERMISSION_NEED_OS" in
                    [Yy]) 
                        _OS_PAWNCC="pawncc.exe"
                        _OS_DISABLE_GNU_NANO="true"
                        _OS_WINDOWS=1
                        _OS_GNU_LINUX=0
                        _OS_DARWIN=0
                        break 
                        ;;
                    [Bb]) 
                        _OS_PAWNCC="pawncc"
                        _OS_DISABLE_GNU_NANO="false"
                        _OS_WINDOWS=0
                        _OS_GNU_LINUX=1
                        _OS_DARWIN=0
                        break 
                        ;;
                    [Xx]) 
                        _OS_PAWNCC="pawncc"
                        _OS_DISABLE_GNU_NANO="true"
                        _OS_WINDOWS=0
                        _OS_GNU_LINUX=0
                        _OS_DARWIN=1
                        break 
                        ;;
                    *) 
                        echo -e "$(bash_coltext_r "err:") Invalid selection. Please enter the correct option!"
                        read -r -p "Choose OS for Triops Y) Windows, B) GNU/Linux, X) Darwin (Mac): " PERMISSION_NEED_OS 
                        ;;
                esac
            done
        fi
        
        if [ $_OS_GNU_LINUX == 1 ]; then
            OMP_FOUND=$(find . -maxdepth 1 -type f -name "omp-server" | head -n 1)
            SAMP_FOUND=$(find . -maxdepth 1 -type f -name "samp03svr" | head -n 1)
        elif [[ $_OS_DARWIN == 1 || $_OS_WINDOWS == 1 ]]; then
            OMP_FOUND=$(find . -maxdepth 1 -type f -name "omp-server.exe" | head -n 1)
            SAMP_FOUND=$(find . -maxdepth 1 -type f -name "samp-server.exe" | head -n 1)
        fi

        if [[ -n "$OMP_FOUND" && -n "$SAMP_FOUND" ]]; then
            echo -e "$(bash_coltext_a ":: Detected both OMP and SAMP servers. Choose mode:")"
            read -r -p "Choose server mode O) OMP, S) SAMP: " CHOOSE_SERVER
            while true; do
                case "$CHOOSE_SERVER" in
                    [Oo])
                        OMP_SERVER=1
                        SAMP_SERVER=0
                        _OS_SSERVER="$(basename "$OMP_FOUND")"
                        break
                        ;;
                    [Ss])
                        OMP_SERVER=0
                        SAMP_SERVER=1
                        _OS_SSERVER="$(basename "$SAMP_FOUND")"
                        break
                        ;;
                    *)
                        echo -e "$(bash_coltext_r "err:") Invalid selection. Please enter O or S!"
                        read -r -p "Choose server mode O) OMP, S) SAMP: " CHOOSE_SERVER
                        ;;
                esac
            done
        elif [[ -n "$OMP_FOUND" ]]; then
            OMP_SERVER=1
            SAMP_SERVER=0
            _OS_SSERVER="$(basename "$OMP_FOUND")"
            LOG_SERVER=$(grep '"file"' config.json | sed -E 's/.*"file": *"([^"]+)".*/\1/')
            pacman_PLUGIN_DIR="components"
        elif [[ -n "$SAMP_FOUND" ]]; then
            OMP_SERVER=0
            SAMP_SERVER=1
            _OS_SSERVER="$(basename "$SAMP_FOUND")"
            LOG_SERVER="server_log.txt"
            pacman_PLUGIN_DIR="plugins"
        else
            echo -e "$(bash_coltext_r "crit:") server not found!. You can get this in \`gamemode\`"
            sleep 1
        fi
    fi
}

