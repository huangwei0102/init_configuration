#! /bin/sh

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

    shopt -s nullglob
    local files=($source_dir/*.tar.gz)

    for file in "${files[@]}"; do
        tar -xzvf "$file" -C "$target_dir"
    done

    shopt -u nullglob
}

copy_config_files_and_directories() {
    local source_dir="$SCRIPTPATH/../tools/conf"
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


# Use the defined function to copy files
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.sh"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.conf"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.zsh"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.lua"
copy_if_exists "$SCRIPTPATH" "$HOME/.local/etc" "*.py"

# Special case: Copy all files in the directory if the directory exists
copy_if_exists "$SCRIPTPATH/../tools/bin" "$HOME/.local/bin" "*"
copy_if_exists "$SCRIPTPATH/../lib/python" "$HOME/.local/lib/python" "*"

# Extract all .tar.gz files from $SCRIPTPATH/../tools/utils to $HOME
extract_tar_gz "$SCRIPTPATH/../tools/utils" "$HOME"

# copy config files and directories
copy_config_files_and_directories


