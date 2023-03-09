#!/bin/bash

backup_image="lscr.io/linuxserver/duplicati:latest"
stopped_container_file="stopped_containers.txt"

# Remove any existing file
if [ -f $stopped_container_file ]; then
    rm -f "$stopped_container_file"
fi

failed=0
for container_id in $(docker ps -q); do
    container_image=$(docker inspect -f '{{.Config.Image}}' "$container_id")

    # Skip backup container
    if [ "$container_image" == "$backup_image" ]; then
        continue
    fi

    # Stop container
    docker stop "$container_id"

    # Check if stopping failed 
    if [ $? -ne 0 ]; then
        echo "Failed to stop container $container_id"
        failed=1
    else
        echo "$container_id" >> "$stopped_container_file"
    fi
done

# Check if file for stopped containers has been created
if [ -f $stopped_container_file ]; then
    echo "Stopped container IDs saved to $stopped_container_file"
else
    echo "Failed to create $stopped_container_file"
fi


if [ $failed -eq 1 ]; then
    exit 1
else
    exit 0
fi