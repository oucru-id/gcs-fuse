#!/bin/bash
set -e

# Check required environment variables
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: BUCKET_NAME environment variable is required"
    exit 1
fi

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

# Handle fuse.conf modification
if [ "$ALLOW_OTHER" = "true" ]; then
    if ! grep -q "user_allow_other" /etc/fuse.conf; then
        echo "user_allow_other" >> /etc/fuse.conf
    fi
fi

# Build gcsfuse command
GCSFUSE_CMD="gcsfuse"
GCSFUSE_CMD="$GCSFUSE_CMD --uid=$FUSE_UID"
GCSFUSE_CMD="$GCSFUSE_CMD --gid=$FUSE_GID"
GCSFUSE_CMD="$GCSFUSE_CMD --file-mode=$FILE_MODE"
GCSFUSE_CMD="$GCSFUSE_CMD --dir-mode=$DIR_MODE"

if [ "$ALLOW_OTHER" = "true" ]; then
    GCSFUSE_CMD="$GCSFUSE_CMD -o allow_other"
fi

if [ "$IMPLICIT_DIRS" = "true" ]; then
    GCSFUSE_CMD="$GCSFUSE_CMD --implicit-dirs"
fi

GCSFUSE_CMD="$GCSFUSE_CMD $BUCKET_NAME $MOUNT_POINT"

echo "Mounting GCS bucket with command: $GCSFUSE_CMD"

# Mount the bucket
eval $GCSFUSE_CMD

echo "GCS bucket mounted successfully!"

# Keep container running
tail -f /dev/null