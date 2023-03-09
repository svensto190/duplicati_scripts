#!/bin/bash

stopped_container_file="stopped_containers.txt"

# Check if file exists
if [ ! -f "$stopped_container_file" ]; then
    echo "Error: "$stopped_container_file" does not exist"
    exit 1
fi

stopped_container_ids=$(<"$stopped_container_file")

failed=0
for container_id in $stopped_container_ids; do
    docker start "$container_id"
    if [ $? -eq 0 ]; then
        # Remove container if successfully started
        sed -i "/$container_id/d" "$stopped_container_file"
    else
        echo "Failed to start container $container_id"
        failed=1
    fi
done

if [ ! -s "$stopped_container_file" ]; then
    rm "$stopped_container_file"
fi


if [ $failed -eq 1 ]; then
    exit 1
else
    exit 0
fi