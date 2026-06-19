#!/bin/bash
set -e

if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Error: GOOGLE_APPLICATION_CREDENTIALS environment variable is required"
    exit 1
fi

# Default values
MOUNT_POINT=${MOUNT_POINT:-/mnt/gcs}
FUSE_UID=${GCSFUSE_UID:-1000}
FUSE_GID=${GCSFUSE_GID:-1000}
FILE_MODE=${FILE_MODE:-777}
DIR_MODE=${DIR_MODE:-777}

build_gcsfuse_cmd() {
    local bucket_name="$1"
    local mount_point="$2"
    local cmd=("gcsfuse")
    cmd+=(--uid "$FUSE_UID")
    cmd+=(--gid "$FUSE_GID")
    cmd+=(--file-mode "$FILE_MODE")
    cmd+=(--dir-mode "$DIR_MODE")

    if [ "$ALLOW_OTHER" = "true" ]; then
        cmd+=("-o" "allow_other")
    fi

    if [ "$IMPLICIT_DIRS" = "true" ]; then
        cmd+=("--implicit-dirs")
    fi

    cmd+=("$bucket_name" "$mount_point")
    printf '%s\n' "${cmd[*]}"
    "${cmd[@]}"
}

# Handle fuse.conf modification
if [ "$ALLOW_OTHER" = "true" ]; then
    if ! grep -q "user_allow_other" /etc/fuse.conf; then
        echo "user_allow_other" >> /etc/fuse.conf
    fi
fi

if [ -n "${MOUNTS:-}" ]; then
    echo "Using multi-mount mode"
    IFS=';' read -ra MOUNT_SPECS <<< "$MOUNTS"
    for spec in "${MOUNT_SPECS[@]}"; do
        if [ -z "$spec" ]; then
            continue
        fi
        bucket_name="${spec%%=*}"
        mount_point="${spec#*=}"
        if [ -z "$bucket_name" ] || [ -z "$mount_point" ] || [ "$bucket_name" = "$mount_point" ]; then
            echo "Error: invalid MOUNTS entry '$spec'. Expected bucket=/mount/path"
            exit 1
        fi
        mkdir -p "$mount_point"
        echo "Mounting GCS bucket '${bucket_name}' to '${mount_point}'"
        build_gcsfuse_cmd "$bucket_name" "$mount_point"
    done
else
    if [ -z "${BUCKET_NAME:-}" ]; then
        echo "Error: BUCKET_NAME environment variable is required when MOUNTS is not set"
        exit 1
    fi
    mkdir -p "$MOUNT_POINT"
    echo "Mounting GCS bucket '${BUCKET_NAME}' to '${MOUNT_POINT}'"
    build_gcsfuse_cmd "$BUCKET_NAME" "$MOUNT_POINT"
fi

echo "GCS bucket mount(s) completed successfully!"

# Keep container running
tail -f /dev/null
