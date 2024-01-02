#!/bin/bash

# Get the IDs of the latest three images for the specified image name
latest_image_ids=$(docker images --format "{{.ID}}" -q rjshk013/node-hellow | head -n 3)

# Remove all other images except the latest three
docker images --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep "rjshk013/node-hellow" | grep -vE "$(echo "$latest_image_ids" | paste -sd '|' -)" | while read -r image_id image_name; do
    docker rmi -f "$image_id"
done
