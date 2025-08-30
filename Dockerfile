FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      curl \
      gnupg \
      lsb-release \
      ca-certificates \
      fuse \
      && rm -rf /var/lib/apt/lists/*

# Add Google Cloud repository and install gcsfuse
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google-archive-keyring.gpg] https://packages.cloud.google.com/apt gcsfuse-focal main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list && \
    apt-get update && \
    apt-get install -y gcsfuse && \
    rm -rf /var/lib/apt/lists/*

# Create mount point
RUN mkdir -p /mnt/gcs

ENV ALLOW_OTHER=false
ENV IMPLICIT_DIRS=false

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]