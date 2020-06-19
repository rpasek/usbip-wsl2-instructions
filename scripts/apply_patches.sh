#!/usr/bin/env bash

# Default values
SRC_DIR=(/usr/src/*microsoft-standard)
PATCH_DIR=./patches

# Other vars
patches=()
dry_run=false

function usage() {
    cat <<EOF
Usage: $0 [-h|--help] [-d|--directory] [-p|--patches] [--dry-run]
  -h|--help        This message
  -d|--directory   Specify the directory of the kernel source code [default: $SRC_DIR]
  -p|--patches     Specify the directory of the patches to be applied [default: $PATCH_DIR]
  --dry-run        Find patches, but output only the patch commands that will be used without applying the actual patches [default: false]
EOF
}

# Find and store all patches in the given patch directory
function find_patches() {
    patches=($PATCH_DIR/*.patch)
    echo "Found patches: ${patches[@]}"
}

# Apply all of the found patch files to the specified directory
function apply_patches() {
    for patch in "${patches[@]}" ; do
        echo "Applying patch: $patch"
        echo "patch -d $SRC_DIR -p1 < $patch"
        if [ "$dry_run" != true ]; then
            patch -d $SRC_DIR -p1 < $patch
        fi
    done
}

# Read and apply args (if present)
function read_args() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h | --help)
                usage "$@"
                exit 0
                ;;
            -d | --directory)
                SRC_DIR=$1
                shift
                ;;
            -p | --patches)
                PATCH_DIR=$1
                shift
                ;;
            --dry-run)
                dry_run=true
                ;;
            *)
                echo "Unknown option: $1"
                usage "$@"
                exit 1
                ;;
        esac
    done
}


# Main function
# delegates to subroutines
function main() {
    read_args "$@"
    find_patches
    apply_patches
    exit 0
}


# run
main "$@"
