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

# Default values - using different variable names to avoid conflicts
MOUNT_POINT=${MOUNT_POINT:-/mnt/gcs}
FUSE_UID=${GCSFUSE_UID:-1001}
FUSE_GID=${GCSFUSE_GID:-1001}
FILE_MODE=${FILE_MODE:-664}
DIR_MODE=${DIR_MODE:-775}

echo "Mounting GCS bucket: $BUCKET_NAME"
echo "Mount point: $MOUNT_POINT"
echo "UID: $FUSE_UID, GID: $FUSE_GID"

# Mount the bucket
gcsfuse \
    --uid=$FUSE_UID \
    --gid=$FUSE_GID \
    --file-mode=$FILE_MODE \
    --dir-mode=$DIR_MODE \
    --implicit-dirs \
    --rename-dir-limit=100 \
    --stat-cache-ttl=1h \
    --type-cache-ttl=1h \
    --debug_fuse \
    --debug_gcs \
    $BUCKET_NAME $MOUNT_POINT

echo "GCS bucket mounted successfully!"

# Keep container running
tail -f /dev/null