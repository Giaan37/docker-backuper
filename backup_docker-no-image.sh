#!/bin/bash

docker stop open-webui portainer comfyui-cu124 n8n
# Variables
BACKUP_DIR="/home/glmds/Desktop/dockers"  # Change this to your desired backup directory
DATE=$(date +"%Y%m%d_%H%M%S")
#BACKUP_IMAGES="$BACKUP_DIR/images/"
BACKUP_VOLUMES="$BACKUP_DIR/volumes/"
BACKUP_CONTAINERS="$BACKUP_DIR/containers_$DATE/"

# Create backup directories if they don't exist
mkdir -p "$BACKUP_IMAGES" "$BACKUP_VOLUMES" "$BACKUP_CONTAINERS"

#
# Step 2: Backup Docker Volumes
echo "Backing up Docker volumes..."
volume_list=($(docker volume ls -q))
total_volumes=${#volume_list[@]}
count=0

for volume in "${volume_list[@]}"; do
    echo "Backing up volume: $volume"
    docker run --rm -v "$volume":/volume -v "$BACKUP_VOLUMES":/backup alpine sh -c \
        "cd /volume && tar czf /backup/$volume.tar.gz ."

    count=$((count + 1))
    progress=$((count * 100 / total_volumes))
    echo -ne "Progress: $progress% \r"
done
echo -e "\nDocker volumes backed up to $BACKUP_VOLUMES"

# Step 3: Backup Running Containers (optional)
echo "Backing up running containers (optional)..."
container_list=($(docker ps -q))
total_containers=${#container_list[@]}
count=0

for container in "${container_list[@]}"; do
    echo "Backing up container: $container"
    docker export "$container" -o "$BACKUP_CONTAINERS/$container.tar"

    count=$((count + 1))
    progress=$((count * 100 / total_containers))
    echo -ne "Progress: $progress% \r"
done
echo -e "\nDocker containers backed up to $BACKUP_CONTAINERS"

echo "Backup completed!"
