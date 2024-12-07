#!/bin/bash

# Variables
BACKUP_DIR="/media/glmds/7c541507-377b-486e-ba42-3d4daeb9aeb9/backups/"  # Change this to your backup directory
BACKUP_IMAGES="$BACKUP_DIR/images/"
BACKUP_VOLUMES="$BACKUP_DIR/volumes/"
BACKUP_CONTAINERS="$BACKUP_DIR/containers/"

# Step 1: Restore Docker Images
echo "Restoring Docker images..."
for image_backup in "$BACKUP_IMAGES"*.tar; do
    [ -e "$image_backup" ] || continue
    docker load -i "$image_backup"
    echo "Restored image from $image_backup"
done
echo "Docker images restored."

# Step 2: Restore Docker Volumes
echo "Restoring Docker volumes..."
for volume_backup in "$BACKUP_VOLUMES"*.tar.gz; do
    [ -e "$volume_backup" ] || continue
    volume_name=$(basename "$volume_backup" .tar.gz)
    if ! docker volume ls -q | grep -wq "$volume_name"; then
        docker volume create "$volume_name"
    fi
    docker run --rm -v "$volume_name":/volume -v "$BACKUP_VOLUMES":/backup alpine sh -c \
        "tar xzf /backup/$(basename "$volume_backup") -C /volume"
    echo "Restored volume $volume_name from $volume_backup"
done
echo "Docker volumes restored."

# Step 3: Restore Docker Containers (optional)
echo "Restoring Docker containers..."
for container_backup in "$BACKUP_CONTAINERS"*.tar; do
    [ -e "$container_backup" ] || continue
    container_name=$(basename "$container_backup" .tar)
    docker import "$container_backup" "$container_name"
    echo "Restored container $container_name from $container_backup"
done
echo "Docker containers restored."

echo "Restore completed!"
