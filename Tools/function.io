#!/bin/bash

function triops_servers() {
    if [ $_OS_DARWIN == 1 ]; then
        ignore_this docker stop $_OS_SSERVER
    elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
        if [ -f "$STRING_LOCK_NAME_SERVER" ]; then
            PID=$(cat "$STRING_LOCK_NAME_SERVER")
            ignore_this kill -9 "$PID"
            rm "$STRING_LOCK_NAME_SERVER"
        fi
    fi
    
    ignore_this sleep 1

    ignore_this rm "$BASH_DIR/$LOG_SERVER"

    ignore_this sleep 1

    if [ ! -f "$BASH_DIR/$_OS_SSERVER" ]; then
        echo -e "$(bash_coltext_r "crit:") $_OS_SSERVER not found!. You can get this in \`gamemode\`"
        echo
        read -r -p "install now? [y/n] " INSTALL_NOW

        while true; do
            case "$INSTALL_NOW" in
                [Yy])
                    what_is_choice_samp ""
                    ;;
                [Nn])
                    bash_typeof ""
                    ;;
                *)
                    what_is_choice_samp ""
                    ;;
            esac
        done
    fi

    cd "$BASH_DIR" || echo

    if [ ! -f "$STRING_LOCK_NAME_SERVER" ]; then
        : ' Create Lock File '
        touch "$STRING_LOCK_NAME_SERVER"
        echo "$SERVER_DOUBLE_SHA256" > "$STRING_LOCK_NAME_SERVER"
    fi

    chmod 777 "$_OS_SSERVER"
    
    ( 
        if [ "$_OS_DARWIN" == 1 ]; then
            docker run --rm -v "$(pwd)":/app ubuntu /app/"$_OS_SSERVER"
        elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
            ignore_this exec -a "$SERVER_DOUBLE_SHA256" ./"$_OS_SSERVER"
        fi
    ) &
    pid=$!

    echo "Starting.."
    sleep 2 > /dev/null

    if ! kill -0 $pid 2>/dev/null; then
        status=1
    else
        status=0
    fi

    if [ $status -ne 0 ]; then
        BASH_TITLE="running - failed"
        bash_title "$SHUSERS:~/ $BASH_TITLE"

        echo
        echo -e "$(bash_coltext_r "# Fail")"
        echo
        if [ -f "$LOG_SERVER" ]; then
            sleep 2 > /dev/null
            cat $LOG_SERVER
            echo
        else
            echo "# $LOG_SERVER not found."
        fi

        echo -e "$(bash_coltext_y "# End.")"
        echo
        bash_typeof ""
    else
        echo
        echo -e "$(bash_coltext_y "# Success")"
        echo

        sleep 2 > /dev/null
        if grep -i "error" $LOG_SERVER > /dev/null; then
            start_true ""
        else
            start_false ""
        fi

        if [ $SERVERS_NEXT == 2 ]; then
            if [ $_OS_DARWIN == 1 ]; then
                ignore_this docker stop $_OS_SSERVER
            elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
                if [ -f "$STRING_LOCK_NAME_SERVER" ]; then
                    PID=$(cat "$STRING_LOCK_NAME_SERVER")
                    ignore_this kill -9 "$PID"
                    rm "$STRING_LOCK_NAME_SERVER"
                fi
            fi
        fi
    fi
}
export triops_servers

function withArgs_triops_servers() {
    if [ $_OS_DARWIN == 1 ]; then
        ignore_this docker stop $_OS_SSERVER
    elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
        if [ -f "$STRING_LOCK_NAME_SERVER" ]; then
            PID=$(cat "$STRING_LOCK_NAME_SERVER")
            ignore_this kill -9 "$PID"
            rm "$STRING_LOCK_NAME_SERVER"
        fi
    fi
    
    ignore_this sleep 1
    
    ignore_this rm "$BASH_DIR/$LOG_SERVER"

    ignore_this sleep 1

    local OPS_FIND_INPUT=$1
    
    if [ $SAMP_SERVER == 1 ]; then
        if [ ! -f "server.cfg" ]; then
            echo "server.cfg not found!"
            bash_end ""
        fi

        mv server.cfg server.cfg.bak
        
        awk -v new_gamemode="$OPS_FIND_INPUT" '
            /^gamemode0 / {$2=new_gamemode} 1' server.cfg.bak > server.cfg || \
                sed -E "s/^(gamemode0 )[0-9]+/\1$OPS_FIND_INPUT/" server.cfg.bak > server.cfg

        echo ":: New server.cfg created with gamemode: $OPS_FIND_INPUT"
    elif [ $OMP_SERVER == 1 ]; then
        mv config.json config.json.bak
     
        if [ ! -f "config.json" ]; then
            echo "config.json not found!"
            bash_end ""
        fi
        
        awk -v new_value="$OPS_FIND_INPUT" '
            /"main_scripts": \[/ {print; getline; print "    \"" new_value "\""; next}
            1' config.json > config.json.bak && mv config.json.bak config.json
            
        echo ":: New config.json created with gamemode: $OPS_FIND_INPUT"
    fi
    
    if [ ! -f "$BASH_DIR/$_OS_SSERVER" ]; then
        echo -e "$(bash_coltext_r "crit:") $_OS_SSERVER not found!. You can get this in \`gamemode\`"
        echo
        read -r -p "install now? [y/n] " INSTALL_NOW

        while true; do
            case "$INSTALL_NOW" in
                [Yy])
                    what_is_choice_samp ""
                    ;;
                [Nn])
                    bash_typeof ""
                    ;;
                *)
                    what_is_choice_samp ""
                    ;;
            esac
        done
    else
        if [ ! -f "$STRING_LOCK_NAME_SERVER" ]; then
            : ' Create Lock File '
            touch "$STRING_LOCK_NAME_SERVER"
            echo "$SERVER_DOUBLE_SHA256" > "$STRING_LOCK_NAME_SERVER"
        fi

        chmod 777 "$_OS_SSERVER"

        ( 
            if [ "$_OS_DARWIN" == 1 ]; then
                docker run --rm -v "$(pwd)":/app ubuntu /app/"$_OS_SSERVER"
            elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
                ignore_this exec -a "$SERVER_DOUBLE_SHA256" ./"$_OS_SSERVER"
            fi
        ) &
        pid=$!

        echo "Starting.."
        sleep 2 > /dev/null

        if ! kill -0 $pid 2>/dev/null; then
            status=1
        else
            status=0
        fi

        if [ $status -ne 0 ]; then
            BASH_TITLE="running - failed"
            bash_title "$SHUSERS:~/ $BASH_TITLE"

            echo
            echo -e "$(bash_coltext_r "# Fail")"
            echo
            if [ -f "$LOG_SERVER" ]; then
                sleep 2 > /dev/null
                cat $LOG_SERVER.txt
                echo
            else
                echo "# $LOG_SERVER not found."
            fi

            echo -e "$(bash_coltext_y "# End.")"
            echo
            bash_typeof ""
        else
            echo
            echo -e "$(bash_coltext_y "# Success")"
            echo

            sleep 2 > /dev/null
            if grep -i "error" $LOG_SERVER > /dev/null; then
                start_true ""
            else
                start_false ""
            fi
        fi

        if [ $SERVERS_NEXT == 2 ]; then
            if [ $_OS_DARWIN == 1 ]; then
                ignore_this docker stop $_OS_SSERVER
            elif [ "$_OS_GNU_LINUX" == 1 ] || [ "$_OS_WINDOWS" == 1 ]; then 
                if [ -f "$STRING_LOCK_NAME_SERVER" ]; then
                    PID=$(cat "$STRING_LOCK_NAME_SERVER")
                    ignore_this kill -9 "$PID"
                    rm "$STRING_LOCK_NAME_SERVER"
                fi
            fi
        fi
    fi
    
    if [ $SAMP_SERVER == 1 ]; then
        rm -f server.cfg
        mv server.cfg.bak server.cfg
        echo "Original server.cfg has been restored."
    elif [ $OMP_SERVER == 1 ]; then
        rm -f config.json
        mv config.json.bak config.json
        echo "Original config.json has been restored."
    fi
}
export withArgs_triops_servers

function fetch_now()
{
    lat=""
    if [ -f "$BASH_DIR/.commits" ]; then
        cur=$(cat "$BASH_DIR/.commits" 2>/dev/null)
    else
        cur=""
    fi
    
    lat=$(curl -s "https://api.github.com/repos/vilksons/triops/commits/main" | grep -o '"sha": "[^"]*' | awk -F': "' '{print $2}')
    
    echo -e "
d888888b d8888b. d888888b  .d88b.  d8888b. .d8888. 
\`~~88~~' 88  \`8D   \`88'   .8P  Y8. 88  \`8D 88'  YP 
88    88oobY'    88    88    88 88oodD' \`8bo.   
88    88\`8b      88    88    88 88~~~     \`Y8b. 
88    88 \`88.   .88.   \`8b  d8' 88      db   8D 
YP    88   YD Y888888P  \`Y88P'  88      \`8888Y' 
"


    if [[ "$lat" == "$cur" ]]; then
        echo "Triops is up-to-date."
    else
        echo "Triops is behind the times"
    fi
    
    echo "Triops Licenses: $LICENSES"

    FIND_PLATFORM=""
    if [ $_OS_GNU_LINUX == 1 ]; then FIND_PLATFORM="Linux"; fi
    if [ $_OS_WINDOWS == 1 ]; then FIND_PLATFORM="${FIND_PLATFORM:+$FIND_PLATFORM & }Windows"; fi
    if [ $_OS_DARWIN == 1 ]; then FIND_PLATFORM="${FIND_PLATFORM:+$FIND_PLATFORM & }Darwin / MacOS"; fi

    if [ -n "$FIND_PLATFORM" ]; then
        echo "Triops Platform: $FIND_PLATFORM"
    else
        echo "Triops Platform: Unknown"
    fi
    bash_end ""
}
export fetch_now