#!/bin/bash

# Variables
BACKUP_DIR="/media/glmds/7c541507-377b-486e-ba42-3d4daeb9aeb9/backups/"  # Change this to your backup directory
BACKUP_IMAGES="$BACKUP_DIR/docker_images_*"
BACKUP_VOLUMES="$BACKUP_DIR/docker_volumes_*"
BACKUP_CONTAINERS="$BACKUP_DIR/docker_containers_*"

# Step 1: Restore Docker Images
echo "Restoring Docker images..."
image_list=($BACKUP_IMAGES)
total_images=${#image_list[@]}
count=0

for image_backup in "${image_list[@]}"; do
  if [ -f "$image_backup" ]; then
    docker load -i "$image_backup"
    echo "Restored image from $image_backup"
  fi

  # Calculate progress and display percentage
  count=$((count + 1))
  progress=$((count * 100 / total_images))
  echo -ne "Progress: $progress% \r"
done
echo -e "\nDocker images restored."

# Step 2: Restore Docker Volumes
echo "Restoring Docker volumes..."
volume_list=($BACKUP_VOLUMES)
total_volumes=${#volume_list[@]}
count=0

for volume_backup in "${volume_list[@]}"; do
  if [ -f "$volume_backup" ]; then
    volume_name=$(basename "$volume_backup" .tar.gz)
    echo "Restoring volume: $volume_name"

    # Create the volume if it doesn't exist
    docker volume create "$volume_name"

    # Restore the volume contents
    docker run --rm -v "$volume_name":/volume -v "$(dirname "$volume_backup")":/backup alpine \
      tar xzf "/backup/$(basename "$volume_backup")" -C /volume

    echo "Restored volume $volume_name from $volume_backup"
  fi

  # Calculate progress and display percentage
  count=$((count + 1))
  progress=$((count * 100 / total_volumes))
  echo -ne "Progress: $progress% \r"
done
echo -e "\nDocker volumes restored."

# Step 3: Restore Docker Containers (optional)
echo "Restoring Docker containers (optional)..."
container_list=($BACKUP_CONTAINERS)
total_containers=${#container_list[@]}
count=0

for container_backup in "${container_list[@]}"; do
  if [ -f "$container_backup" ]; then
    container_name=$(basename "$container_backup" .tar)
    echo "Restoring container: $container_name"

    # Import the container image
    cat "$container_backup" | docker import - "$container_name"
    echo "Restored container $container_name from $container_backup"
  fi

  # Calculate progress and display percentage
  count=$((count + 1))
  progress=$((count * 100 / total_containers))
  echo -ne "Progress: $progress% \r"
done
echo -e "\nDocker containers restored."

echo "Restore completed!"

