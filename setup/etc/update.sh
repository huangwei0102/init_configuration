#! /bin/bash

SCRIPT=$(readlink -f "$0" || echo "$0")
SCRIPTPATH=$(dirname "$SCRIPT")


[ ! -d "$HOME/.local" ] && mkdir -p "$HOME/.local" 2> /dev/null
[ ! -d "$HOME/.local/etc" ] && mkdir -p "$HOME/.local/etc" 2> /dev/null
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin" 2> /dev/null
[ ! -d "$HOME/.local/lib" ] && mkdir -p "$HOME/.local/lib" 2> /dev/null
[ ! -d "$HOME/.local/lib/python" ] && mkdir -p "$HOME/.local/lib/python" 2> /dev/null
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config" 2> /dev/null


# Define a function to copy matching files if they exist, does not perform copying if no matching files are found
copy_if_exists() {
    local source_path="$1"
    local target_path="$2"
    local pattern="$3"

    # Enable nullglob to treat non-matching globs as empty strings
    shopt -s nullglob
    local files=($source_path/$pattern)

    # Perform copying if matching files are found
    if [ ${#files[@]} -gt 0 ]; then
        cp "${files[@]}" "$target_path"
    fi

    # Disable nullglob option
    shopt -u nullglob
}

# Function to extract all .tar.gz files from a specific directory to $HOME
extract_tar_gz() {
    local source_dir="$1"
    local target_dir="$2"

    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"

    shopt -s nullglob
    local files=($source_dir/*.tar.gz)

    for file in "${files[@]}"; do
        tar -xzvf "$file" -C "$target_dir"
    done

    shopt -u nullglob
}

copy_config_files_and_directories() {
    local source_dir="$SCRIPTPATH/../../packages/resources/conf"
    local target_dir="$HOME"

    # Loop through each item in the source directory
    for item in "$source_dir"/* "$source_dir"/.*; do
        if [ -f "$item" ]; then
            # It's a file, copy directly to target directory
            cp "$item" "$target_dir"
        elif [ -d "$item" ] && [ "$(basename "$item")" != "." ] && [ "$(basename "$item")" != ".." ]; then
            # It's a directory, create corresponding directory in target and copy files
            local dir_name=$(basename "$item")
            mkdir -p "$target_dir/$dir_name"
            cp "$item"/* "$target_dir/$dir_name/"
        fi
    done
}


# deploy files to $HOME/.local/etc
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.sh"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.conf"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.zsh"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.lua"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.py"

PACKAGES_PATH="$SCRIPTPATH/../../packages"

# deploy files from $PACKAGES_PATH/bin to $HOME/.local/bin
copy_if_exists "$PACKAGES_PATH/bin" "$HOME/.local/bin" "*"

# deploy files from $PACKAGES_PATH/lib/python to $HOME/.local/lib/python
copy_if_exists "$PACKAGES_PATH/lib/python" "$HOME/.local/lib/python" "*"

# Extract all .tar.gz files from $PACKAGES_PATH/resources/softwares to $HOME/softwares
extract_tar_gz "$PACKAGES_PATH/resources/softwares" "$HOME/softwares"

# copy config files and directories
copy_config_files_and_directories


