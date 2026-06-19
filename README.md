# GCS-Fuse Docker Configurations

This repository contains Docker configurations for integrating Google Cloud Storage (GCS) with a FUSE filesystem using `gcs-fuse`. The `demo` folder is specifically for demonstrating the mounting of Kobo media files.

## Setup

1.  **Google Cloud Service Account Key**: Place your Google Cloud service account key file (e.g., `sa-key.json`) in the `demo/kobo/` directory.

2.  **Environment Variables**: The `docker-compose.yml` file in `demo/kobo/` uses environment variables directly. You can modify these values in the `docker-compose.yml` file itself.

    -   `GOOGLE_APPLICATION_CREDENTIALS`: Path to your service account key within the container (e.g., `/keys/sa-key.json`).
    -   `BUCKET_NAME`: The name of your GCS bucket.
    -   `MOUNT_POINT`: The directory inside the container where the GCS bucket will be mounted.
    -   `GCSFUSE_UID`: User ID for the `gcsfuse` process.
    -   `GCSFUSE_GID`: Group ID for the `gcsfuse` process.
    -   `FILE_MODE`: File permissions for mounted files.
    -   `DIR_MODE`: Directory permissions for mounted directories.
    -   `MOUNTS`: Optional multi-mount mode. Semicolon-separated entries in the form `bucket=/mount/path;bucket-two=/mount/path-two`. When `MOUNTS` is set, `BUCKET_NAME` and `MOUNT_POINT` are ignored.

## Running the Demo

Navigate to the `demo/kobo/` directory and run:

```bash
docker-compose up
```

This will build and start the `gcsfuse` service, mounting your specified GCS bucket to the `MOUNT_POINT` inside the container.

## Multi-mount mode

You can mount multiple buckets from one container by setting:

```env
MOUNTS=bucket-one=/mnt/kpi;bucket-two=/mnt/kobocat
```

In that mode, bind mount each target path from the host into the container with
shared propagation, for example:

```yaml
volumes:
  - ./sa-key.json:/keys/sa-key.json:ro
  - /opt/kobo/data/kpi_media:/mnt/kpi:shared
  - /opt/kobo/data/kobocat_media_uploads:/mnt/kobocat:shared
```
