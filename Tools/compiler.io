#!/usr/bin/bash

function triops_compilers() {
    SHFILE="false"

    while IFS= read -r -d '' pawncc; do
        if [ -f "$pawncc" ]; then
            COMPILER_PAWNCC="$pawncc"
            break
        fi
    done < <(find "$BASH_DIR" -type f -iname "$_OS_PAWNCC" -print0)

    if [ -z "$COMPILER_PAWNCC" ]; then
        echo -e "$(bash_coltext_r "crit:") $_OS_PAWNCC not found!. You can get this in \`pawncc\`"
        echo
        read -r -p "install now? [y/n] " INSTALL_NOW

        while true; do
            case "$INSTALL_NOW" in
                [Yy])
                    what_is_choice_pawncc ""
                    ;;
                [Nn])
                    bash_typeof ""
                    ;;
                *)
                    what_is_choice_pawncc ""
                    ;;
            esac
        done
    fi

    : '
        @Map
    '
    files=()
    while IFS= read -r -d '' COMPILED_FILES; do
        files+=("$COMPILED_FILES")
    done < <(find "$BASH_DIR" -name "*.io*" -type f -print0)

    for COMPILED_FILES in "${files[@]}"; do
        if [ -f "$COMPILED_FILES" ] && [[ "$COMPILED_FILES" != *.amx ]]; then
            SHFILE="true"
            bash_title "$COMPILED_FILES"

            AMX_O="$(dirname "$COMPILED_FILES")/$(basename "${COMPILED_FILES%.io*}.amx")"

            echo -e "$(bash_coltext_y "dbg:") Processing: $COMPILED_FILES"

            : '
                @PawnCC.Compile
            '
            
            INCLUDE_GAMEMODES_DIRS=$(find "gamemodes" -type d | tr '\n' ':')
            INCLUDE_GAMEMODES_DIRS=${INCLUDE_DIRS%:}
            
            start_time=$(date +%s%3N)

                for _ in {1..10}; do
                    "$COMPILER_PAWNCC" -i"$TRIOPS_DEFAULT_INCLUDE" -i"$TRIOPS_ALLOW_EXCLUDE" -i"$INCLUDE_GAMEMODES_DIRS" "$COMPILED_FILES" -o"$AMX_O" "$AMX_OPT_F" > "$METADAT_FILE" 2>&1
                done

            end_time=$(date +%s%3N)

            elapsed=$((end_time - start_time))
            avg_time=$((elapsed / 10))

            bash_cache_compiler ""
            sleep 0.1 > /dev/null &&
            cat "$METADAT_FILE"

            if [ -s "$AMX_O" ]; then
                echo
                echo "~ $AMX_O"
                if [ "$COMPILER_MODE" == "true" ]; then
                    BASH_TITLE="compilers"
                    bash_title "$SHUSERS:~/ $BASH_TITLE"
                elif [ "$COMPILER_MODE" == "false" ]; then
                    BASH_TITLE="compiler - running"
                    bash_title "$SHUSERS:~/ $BASH_TITLE"
                fi
                echo
                echo "total size: $(stat -c%s "$AMX_O") bytes"
                echo "Total execution time: ${elapsed} ms"
                echo "Average time per iteration: ${avg_time} ms"
            fi
        fi
    done

    if [ "$SHFILE" == "false" ]; then
        echo -e "$(bash_coltext_r "..io not found!")"
        echo
        bash_end ""
    fi
    if [[ "$COMPILER_MODE" == "true" || "$COMPILER_MODE" == "null" || "$COMPILER_MODE" == "" ]]; then
        bash_end ""
    elif [ "$COMPILER_MODE" == "false" ]; then
        triops_servers ""
    fi
}
export triops_compilers

function bash_cache_compiler() {
    cache_compiler=".cache/compiler.log"
    _cache_compiler=".cache/.compiler.log"
    if [ -f "$_cache_compiler" ]; then
        rm "$_cache_compiler"
    fi
    while IFS= read -r line; do
        echo "~" >> "$_cache_compiler"
        echo "$line" >> "$_cache_compiler"
    done < "$cache_compiler"
    mv "$_cache_compiler" "$cache_compiler" > /dev/null
}
export bash_cache_compiler

function bash_check_dir() {
    local folder=$1
    if [ -d "$folder" ]; then
        echo
        echo "# $folder is .. Ok .."
        echo " [A subdirectory or file $folder already exists.]"
        echo "-"

        sleep 0.100 > /dev/null &&
        return
    else
        mkdir -p "$folder"
        echo ":: Create? '$BASH_DIR/$folder'...: [yes]"
        
        sleep 0.200 > /dev/null

        if [ "$folder" == "gamemodes" ]; then
            cat <<EOF > gamemodes/main.io.pwn
#include <a_samp>

main() {
    print("Hello, World!");
}
EOF
        fi

        return
    fi
}
export bash_check_dir

start_true() {
    : '
        @strain.True
    '
    echo -e "$(bash_coltext_r "~")"
    echo "    ; \"error\"   .. Yes .. True"
    error_cache ""
}
export start_true

start_false() {
    : '
        @strain.False
    '
    echo -e "$(bash_coltext_y "~")"
    echo "    ; \"error\"   .. No .. False"
    check2 ""
}
export start_false

start_true2() {
    : '
        @strain.True2
    '
    echo -e "$(bash_coltext_r "~")"
    echo "    ; \"failed\"  .. Yes .. True"
    failed_cache ""
}
export start_true2

start_false2() {
    : '
        @strain.False2
    '
    echo -e "$(bash_coltext_y "~")"
    echo "    ; \"failed\"  .. No .. False"
    check3 ""
}
export start_false2

start_true3() {
    : '
        @strain.True3
    '
    echo -e "$(bash_coltext_r "~")"
    echo "    ; \"invalid\" .. Yes .. True"
    invalid_cache ""
}
export start_true3

start_false3() {
    : '
        @strain.False3
    '
    echo -e "$(bash_coltext_y "~")"
    echo "    ; \"invalid\" .. No .. False"
    echo
    bash_end ""
}
export start_false3

error_cache() {
    : '
        @strain.Error
    '
    echo
    grep -i "error" $LOG_SERVER
    echo
    check2 ""
}
export error_cache

failed_cache() {
    : '
        @strain.Failed
    '
    echo
    grep -i "failed" $LOG_SERVER
    echo
    check3 ""
}
export failed_cache

invalid_cache() {
    : '
        @strain.Invalid
    '
    echo
    grep -i "invalid" $LOG_SERVER
    echo
    bash_end ""
}
export invalid_cache

check2() {
    if grep -i "failed" $LOG_SERVER > /dev/null; then
        start_true2 ""
    else
        start_false2 ""
    fi
}
export check2

check3() {
    if grep -i "invalid" $LOG_SERVER > /dev/null; then
        start_true3 ""
    else
        start_false3 ""
    fi
}
export check3

ok_next() {
    : '
        @Func.OK_Next
    '
    echo -e "$(bash_coltext_y "Press any key to running.")"
    echo
    read -r -n 1 -s
    triops_servers ""
}
export ok_next

function what_is_choice_samp()
{
    while true; do
        echo "# Select: [L]inux for Linux Files [W]indows for Windows Files"
        read -r -p ">> " SEL_CO
        case "$SEL_CO" in
            [Ll])
                send_samp_linux "" && break ;;
            [Ww])
                send_samp_win "" && break ;;
            *)
                echo -e "$(bash_coltext_r "err:") Invalid selection. Please enter L or W." ;;
        esac
    done
}
export what_is_choice_samp

function what_is_choice_pawncc()
{
    while true; do
        echo "# Select: [L]inux for Linux Files [W]indows for Windows Files"
        read -r -p ">> " SEL_CO
        case "$SEL_CO" in
            [Ll])
                send_compilers_linux "" && break ;;
            [Ww])
                send_compilers_win "" && break ;;
            *)
                echo -e "$(bash_coltext_r "err:") Invalid selection. Please enter L or W." ;;
        esac
    done
}
export what_is_choice_pawncc
