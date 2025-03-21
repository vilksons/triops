#!/usr/bin/bash

function bash_typeof_pacman() {
    if [ ! -f "pacman.json" ]; then
python3 -c 'import json, os
if not os.path.isfile("pacman.json"):
    data = {
        "package": [
            "github/example/user/repository",
            "github/example/user/repository/to/files/.zip",
            "github/example/user/repository/to/files/.tar.gz",
            "gitlab/example/user/repository",
            "gitlab/example/user/repository/to/files/.zip",
            "gitlab/example/user/repository/to/files/.tar.gz",
            "sourceforge/example/user/repository",
            "sourceforge/example/user/repository/to/files/.zip",
            "sourceforge/example/user/repository/to/files/.tar.gz",
            "unknownhost/example/path/to/target",
            "unknownhost/example/path/to/target/to/files/.zip",
            "unknownhost/example/path/to/target/to/files/.tar.gz"
        ]
    }
    with open("pacman.json", "w") as f:
        json.dump(data, f, indent=4)
' 
    fi
    
    BASH_TITLE="TPM Mode"
    bash_title "$BASH_TITLE"

    echo -n "$(bash_coltext_y "$SHUSERS")"
    echo -n ":~$ "
    read -r pacman_OPTION_FLAGS
    bash_TPM ""
}
export bash_typeof_pacman

function bash_TPM()
{
    : '
        TPM Mode
    '

    local pacman_TRIGGER="tpm"
    local pacman_UNKNOWNS_HOST=0

    case "$pacman_OPTION_FLAGS" in
        "install"*)
            BASH_TITLE="TPM Install/Reinstall Package"
            bash_title "$SHUSERS:~/ $BASH_TITLE"

            if [ ! -d "$pacman_DIR" ]; then
                mkdir -p "$pacman_DIR"
            fi

            pacman_repository_url="${pacman_OPTION_FLAGS#"install "}"
            pacman_repository_url="${pacman_repository_url#install }"

            if [[ -n "$pacman_repository_url" && "$pacman_repository_url" != "install" ]]; then
                pacman_URLS=("$pacman_repository_url")
            else
                pacman_URLS=()
                    while IFS= read -r line; do
                        pacman_URLS+=("$line")
                    done < <(process_package "$pacman.json" || echo "error load json for : \"package\"")
            fi

            for pacman_repository_url in "${pacman_URLS[@]}"; do
                : ' array to variable '

                if [[ "$pacman_repository_url" != https://* ]]; then
                : ' tpm: package URL to https
                '
                    if [[ "$pacman_repository_url" == github/* ]]; then
                        : ' github '
                        pacman_repository_url="https://github.com/${pacman_repository_url#github/}"
                    elif [[ "$pacman_repository_url" == gitlab/* ]]; then
                        : ' gitlab '
                        pacman_repository_url="https://gitlab.com/${pacman_repository_url#gitlab/}"
                    elif [[ "$pacman_repository_url" == sourceforge/* ]]; then
                        : ' sourceforge '
                        pacman_repository_url="https://sourceforge.net/projects/${pacman_repository_url#sourceforge/}"
                    else
                        : ' unknown '
                        echo "$(bash_coltext_g "warn:") host url unknown's: $pacman_API_URL..."
                        pacman_UNKNOWNS_HOST=1
                        continue
                    fi
                fi
                
                if [[ "$pacman_repository_url" == *"/releases/download/"* ]]; then
                    pacman_archive_url="$pacman_repository_url"
                elif [[ "$pacman_repository_url" == *"/releases/tag/"* ]]; then
                    pacman_REPO_NAME=$(echo "$pacman_repository_url" | awk -F '/' '{print $(NF-3) "/" $(NF-2)}')
                    pacman_TAG_VERSION=$(echo "$pacman_repository_url" | awk -F '/' '{print $NF}')
                
                    if [[ "$pacman_repository_url" == *"github.com"* ]]; then
                        : ' github '
                        pacman_API_URL="https://api.github.com/repos/$pacman_REPO_NAME/git/refs/tags/$pacman_TAG_VERSION"
                    elif [[ "$pacman_repository_url" == *"gitlab.com"* ]]; then
                        : ' gitlab '
                        pacman_API_URL="https://gitlab.com/api/v4/projects/$(echo "$pacman_REPO_NAME" | tr '/' '%2F')/releases/$pacman_TAG_VERSION"
                    elif [[ "$pacman_repository_url" == *"sourceforge.net"* ]]; then
                        : ' sourceforge '
                        pacman_API_URL="https://sourceforge.net/projects/$pacman_REPO_NAME/files/latest/download"
                    else
                        : ' unknown '
                        echo "$(bash_coltext_g "warn:") host url unknown's: $pacman_API_URL..."
                        pacman_UNKNOWNS_HOST=1
                        continue
                    fi
                
                    if [ $pacman_UNKNOWNS_HOST == 1 ]; then
                        [[ -z "$pacman_archive_url" ]] && pacman_archive_url=$(curl -s "$pacman_repository_url" | grep "browser_download_url" | grep -E ".zip|.tar.gz" | awk -F '"' '{print $4}' | head -n 1)
                    elif [ $pacman_UNKNOWNS_HOST == 0 ]; then
                        [[ -z "$pacman_archive_url" ]] && pacman_archive_url=$(curl -s "$pacman_API_URL" | grep "browser_download_url" | grep -E ".zip|.tar.gz" | awk -F '"' '{print $4}' | head -n 1)
                    fi
                else
                    pacman_REPO_NAME=$(echo "$pacman_repository_url" | awk -F '/' '{print $(NF-1) "/" $NF}')
                
                    if [[ "$pacman_repository_url" == *"github.com"* ]]; then
                        : ' github '
                        pacman_API_URL="https://api.github.com/repos/$pacman_REPO_NAME/releases/latest"
                    elif [[ "$pacman_repository_url" == *"gitlab.com"* ]]; then
                        : ' gitlab '
                        pacman_API_URL="https://gitlab.com/api/v4/projects/$(echo "$pacman_REPO_NAME" | tr '/' '%2F')/releases/permalink/latest"
                    elif [[ "$pacman_repository_url" == *"sourceforge.net"* ]]; then
                        : ' sourceforge '
                        pacman_archive_url="https://sourceforge.net/projects/$pacman_REPO_NAME/files/latest/download"
                    else
                        : ' unknown '
                        echo "$(bash_coltext_g "warn:") host url unknown's: $pacman_API_URL..."
                        pacman_UNKNOWNS_HOST=1
                        continue
                    fi

                    if [ $pacman_UNKNOWNS_HOST == 1 ]; then
                        [[ -z "$pacman_archive_url" ]] && pacman_archive_url=$(curl -s "$pacman_repository_url" | grep "browser_download_url" | grep -E ".zip|.tar.gz" | awk -F '"' '{print $4}' | head -n 1)
                    elif [ $pacman_UNKNOWNS_HOST == 0 ]; then
                        [[ -z "$pacman_archive_url" ]] && pacman_archive_url=$(curl -s "$pacman_API_URL" | grep "browser_download_url" | grep -E ".zip|.tar.gz" | awk -F '"' '{print $4}' | head -n 1)
                    fi
                fi

                pacman_ARCHIVE_FILE=".tcache.zip"
                pacman_EXTRACT_DIR=".tcache"

                rm -rf "$pacman_EXTRACT_DIR"
                mkdir -p "$pacman_EXTRACT_DIR"

                pacman_FILE_NAME=$(basename "$pacman_repository_url")
                pacman_FILE_NAME="${pacman_FILE_NAME%.*}"
                pacman_EX_VERSION_REPO=""

                if [[ "$pacman_repository_url" == *"/releases/tag/"* ]]; then
                    pacman_VERSION_REPO=$(echo "$pacman_repository_url" | awk -F '/' '{print $NF}')
                elif [[ "$pacman_repository_url" == *"/releases/download/"* ]]; then
                    pacman_VERSION_REPO=$(echo "$pacman_repository_url" | awk -F '/' '{print $(NF-1)}')
                else
                    pacman_VERSION_REPO="Unknown's"
                fi

                pacman_VERSION_REPO=${pacman_VERSION_REPO#v}
                pacman_EX_VERSION_REPO="$pacman_VERSION_REPO"

                if ! [[ "$pacman_VERSION_REPO" =~ [0-9] ]]; then
                    pacman_VERSION_REPO=""
                    pacman_EX_VERSION_REPO="Unknown's"
                fi

                if [[ -z "$pacman_FILE_NAME" ]]; then
                    pacman_FILE_NAME="Unknown's"
                fi

                pacman_FILE_NAME_SAVE="$pacman_FILE_NAME"

                sleep 0.1
                
                pacman_FILE_NAME=$(basename "$pacman_repository_url")
                pacman_FILE_NAME="${pacman_FILE_NAME%%-*}"

                echo -e "$(bash_coltext_y "Downloading") $pacman_FILE_NAME_SAVE $pacman_VERSION_REPO"
                
                wget -q --show-progress -O "$pacman_ARCHIVE_FILE" "$pacman_archive_url"

                mkdir -p "$pacman_PLUGIN_DIR"

                if file "$pacman_ARCHIVE_FILE" | grep -q "Zip archive data"; then
                    unzip -q "$pacman_ARCHIVE_FILE" -d "$pacman_EXTRACT_DIR"
                elif file "$pacman_ARCHIVE_FILE" | grep -q "gzip compressed data"; then
                    mkdir -p "$pacman_EXTRACT_DIR"
                    tar -xzf "$pacman_ARCHIVE_FILE" -C "$pacman_EXTRACT_DIR" --strip-components=1
                else
                    echo -e "$(bash_coltext_r "crit:") Downloaded file is not a valid ZIP or TAR.GZ.."
                    rm -rf "$pacman_ARCHIVE_FILE" "$pacman_EXTRACT_DIR"
                    continue
                fi

                pacman_EXTRACT_SUBDIR=$(find "$pacman_EXTRACT_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
                
                if [[ -d "$pacman_EXTRACT_SUBDIR" ]]; then
                    mv "$pacman_EXTRACT_SUBDIR"/* "$pacman_EXTRACT_DIR/"
                    rm -rf "$pacman_EXTRACT_SUBDIR"
                fi

                echo -e "$(bash_coltext_y "dbg: ")Extraction Directory.."

                find "$pacman_EXTRACT_DIR" -type f -name "*.inc" | while IFS= read -r inc_file; do
                    pacman_REAL_PATH=$(realpath --relative-to="$pacman_EXTRACT_DIR" "$inc_file" 2> /dev/null || echo "$inc_file")

                    if [[ "$pacman_REAL_PATH" =~ (^|/)include/ ]]; then
                        pacman_REAL_PATH="${pacman_REAL_PATH#*include/}"
                    fi

                    if [[ "$pacman_REAL_PATH" == */* ]]; then
                        pacman_DEST_PATH="$pacman_DIR/$(dirname "$pacman_REAL_PATH")"
                    else
                        pacman_DEST_PATH="$pacman_DIR"
                    fi

                    mkdir -p "$pacman_DEST_PATH"
                    mv "$inc_file" "$pacman_DEST_PATH/"
                done

                find "$pacman_EXTRACT_DIR" -type f \( -name "*.dll" -o -name "*.so" \) -exec mv {} "$pacman_PLUGIN_DIR/" \;

                rm -rf "$pacman_ARCHIVE_FILE" "$pacman_EXTRACT_DIR"
                echo -e "$(bash_coltext_y "Complete!.") Packages: $pacman_FILE_NAME_SAVE | $pacman_EX_VERSION_REPO"
            done

            echo -e "$(bash_coltext_y "[All packages installed]")"

            sleep 0.1

            FOUND_pacman_PLUGINS=false
            for ext in ".so" ".dll"; do
                if ls "${pacman_FILE_NAME}"*"$ext" &>/dev/null; then
                    FOUND_pacman_PLUGINS=true
                fi
                if ls "${pacman_FILE_NAME_SAVE}"*"$ext" &>/dev/null; then
                    FOUND_pacman_PLUGINS=true
                fi
            done

            if [ "$FOUND_pacman_PLUGINS" = true ]; then
                pacman_NEWPLG=()
                
                while IFS= read -r line; do
                    if [[ "$line" =~ \.so$|\.dll$ ]]; then
                        plugin_name="$(basename "$line" | sed 's/\.[^.]*$//')"
                        pacman_NEWPLG+=("$plugin_name")
                    fi
                done < "$pacman_FILE_NAME"

                if [[ -f "$pacman_FILE_NAME_SAVE" ]]; then
                    while IFS= read -r line; do
                        if [[ "$line" =~ \.so$|\.dll$ ]]; then
                            plugin_name="$(basename "$line" | sed 's/\.[^.]*$//')"
                            pacman_NEWPLG+=("$plugin_name")
                        fi
                    done < "$pacman_FILE_NAME_SAVE"
                fi

                if [[ $SAMP_SERVER == 1 || $OMP_SERVER == 1 ]]; then
                    if [ ! -f "$server.cfg" ]; then
                        echo -e "$(bash_coltext_g "warn:") $server.cfg not found!."
                        bash_end ""
                    fi
                fi

                if [ ${#pacman_NEWPLG[@]} -gt 0 ]; then
                    if [ $SAMP_SERVER == 1 ]; then
                        if ! grep -q "^plugins " "$server.cfg"; then
                            sed -i '1i plugins ' "$server.cfg"
                        fi
                        
                        _pacman_EXTPLG=$(grep -oP '(?<=plugins ).*' "$server.cfg" | tr ' ' '\n' | sort -u)

                        _pacman_NEWPLG=()
                        for PLUGIN in "${pacman_NEWPLG[@]}"; do
                            if ! echo "$_pacman_EXTPLG" | grep -qx "$PLUGIN"; then
                                _pacman_NEWPLG+=("$PLUGIN")
                            fi
                        done

                        if [ ${#_pacman_NEWPLG[@]} -gt 0 ]; then
                            pacman_UPDATED_PLUGINS=$(echo "$_pacman_EXTPLG" "${_pacman_NEWPLG[@]}" | tr '\n' ' ' | xargs -n1 | sort -u | xargs)
                            sed -i "s/^plugins .*/plugins $pacman_UPDATED_PLUGINS/" "$server.cfg"
                            echo " Added new plugins to server.cfg: ${_pacman_NEWPLG[*]}"
                        else
                            echo -e "$(bash_coltext_y "dbg:") No new plugins need to be added."
                        fi
                    elif [ $OMP_SERVER == 1 ]; then
                        if ! grep -q '"legacy_plugins":' "$config.json"; then
                            sed -i '1i "legacy_plugins": [],' "$config.json"
                        fi
                        
                        _pacman_EXTPLG=$(awk -F'[][]' '/"legacy_plugins":/ {gsub(/"|,/,"",$2); print $2}' "$config.json" | tr '\n' ' ')

                        _pacman_NEWPLG=()
                        for PLUGIN in "${pacman_NEWPLG[@]}"; do
                            if ! echo "$_pacman_EXTPLG" | grep -qw "$PLUGIN"; then
                                _pacman_NEWPLG+=("\"$PLUGIN\"")
                            fi
                        done

                        if [ ${#_pacman_NEWPLG[@]} -gt 0 ]; then
                            pacman_UPDATED_PLUGINS=$(echo "$_pacman_EXTPLG" "${_pacman_NEWPLG[@]}" | tr ' ' '\n' | sort -u | xargs | sed 's/ /", "/g')
                            awk -v plugins="$pacman_UPDATED_PLUGINS" '
                            /"legacy_plugins":/ {print "\"legacy_plugins\": [ " plugins " ],"; next} 
                            {print}
                            ' "$config.json" > temp.json && mv temp.json "$config.json"

                            echo "Added new plugins to legacy_plugins: ${_pacman_NEWPLG[*]}"
                        else
                            echo -e "$(bash_coltext_y "dbg:") No new plugins need to be added."
                        fi
                    fi
                else
                    echo -e "$(bash_coltext_y "dbg:") No valid plugins found in $pacman_FILE_NAME_SAVE."
                fi
            fi

            
            bash_typeof_pacman ""
            ;;
        "remove"*)
            BASH_TITLE="TPM Remove Package"
            bash_title "$SHUSERS:~/ $BASH_TITLE"

            local FOR_FIND_ARGS="${pacman_OPTION_FLAGS#"remove "}"
            local FOR_FIND_ARGS="${FOR_FIND_ARGS#remove }"

            if [[ -n "$FOR_FIND_ARGS" ]]; then
                pacman_REMOVE_PATTERN="$FOR_FIND_ARGS"
            else
                echo ":: Enter the name pattern of the include/plugin to remove:"
                read -r -p ">>> " pacman_REMOVE_PATTERN
            fi
            
            pacman_FILTER_REMOVE_FILES() {
                local pattern="$1"
                while read -r file; do
                    filn=$(basename "$file")
                    if [[ "$filn" =~ ^$pattern(\.[a-z]+)?$ || "$filn" =~ .*-?$pattern(\.[a-z]+)?$ ]]; then
                        echo "$file"
                    fi
                done
            }

            pacman_INC_FILES=$(find "$pacman_DIR" -type f -name "*.inc" | pacman_FILTER_REMOVE_FILES "$pacman_REMOVE_PATTERN")

            if [[ -n "$pacman_INC_FILES" ]]; then
                echo "$pacman_INC_FILES" | xargs rm -rf
                echo -e "$(bash_coltext_y "[OK] ") Removed includes: $pacman_INC_FILES"
            else
                echo -e "$(bash_coltext_y "dbg:") No matching include files found for pattern: $pacman_REMOVE_PATTERN"
            fi

            pacman_PLUGIN_FILES=$(find "$pacman_PLUGIN_DIR" -type f \( -name "*.dll" -o -name "*.so" \) | pacman_FILTER_REMOVE_FILES "$pacman_REMOVE_PATTERN")
            
            if [ $SAMP_SERVER == 1 ]; then
                if [[ -n "$pacman_PLUGIN_FILES" ]]; then
                    echo "$pacman_PLUGIN_FILES" | xargs rm -rf
                    echo -e "$(bash_coltext_y "[OK] ") Removed plugins: $pacman_PLUGIN_FILES"
                else
                    echo -e "$(bash_coltext_y "dbg:") No matching plugins found for pattern: $pacman_REMOVE_PATTERN"
                fi

                if [[ -f "$server.cfg" ]]; then
                    if grep -q "^plugins" "$server.cfg"; then
                        sed -i "/^plugins /s/\b$pacman_REMOVE_PATTERN\(\.so\|\.dll\|\.dylib\|\)//g" "$server.cfg"
                        sed -i 's/  / /g' "$server.cfg"
                        sed -i 's/^plugins *$/plugins /' "$server.cfg"
                        echo -e "$(bash_coltext_y "[OK] ") Removed $pacman_REMOVE_PATTERN from server.cfg"
                    else
                        echo -e "$(bash_coltext_y "dbg:") No 'plugins' entry found in server.cfg"
                    fi
                fi

                echo -e "$(bash_coltext_y "[OK] ") Removal process completed!"
                echo
            elif [ $OMP_SERVER == 1 ]; then
                if [[ -n "$pacman_PLUGIN_FILES" ]]; then
                    echo "$pacman_PLUGIN_FILES" | xargs rm -rf
                    echo -e "$(bash_coltext_y "[OK] ") Removed plugins: $pacman_PLUGIN_FILES"
                else
                    echo -e "$(bash_coltext_y "dbg:") No matching plugins found for pattern: $pacman_REMOVE_PATTERN"
                fi

                if [[ -f "$config.json" ]]; then
                    if grep -q '"legacy_plugins":' "$config.json"; then
                        awk -v pattern="$pacman_REMOVE_PATTERN" '
                        BEGIN { inside_array=0 }
                        /"legacy_plugins": \[/ { inside_array=1; print; next }
                        inside_array && /\]/ { inside_array=0 }
                        inside_array && $0 ~ pattern { next }
                        { print }
                        ' "$config.json" > temp.json && mv temp.json "$config.json"

                        echo -e "$(bash_coltext_y "[OK]") Removed $pacman_REMOVE_PATTERN from config.json"
                    else
                        echo -e "$(bash_coltext_y "dbg:") No 'legacy_plugins' entry found in config.json"
                    fi
                else
                    echo -e "$(bash_coltext_y "dbg:") config.json not found"
                fi
                echo -e "$(bash_coltext_y "[OK] ") Removal process completed!"
                echo 
            fi
            
            bash_typeof_pacman ""
            ;;
        "$BASH_OPTION -C" | "clear" | "cc")
            clear; echo -ne "\033[3J"
            bash_typeof_pacman ""
            ;;
        "$pacman_TRIGGER" | "$pacman_TRIGGER " | "" | " ")
            bash_help2
            bash_typeof_pacman ""
            ;;
        "help" | " ")
            BASH_TITLE="help"
            bash_title "$SHUSERS:~/ $BASH_TITLE"

            bash_help2
            bash_typeof_pacman ""
            ;;
       "exit")
            bash_typeof ""
            ;;
        *)
            echo "error: $pacman_OPTION_FLAGS: command not found"
            bash_typeof_pacman ""
            ;;
    esac
}