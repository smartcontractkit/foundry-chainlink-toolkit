#!/bin/bash

# Check if Docker daemon is running
if ! pgrep -f "docker" > /dev/null; then
  echo "Docker is not running"
  exit 1
fi

# Get the name of the Docker network and containers count from command-line argument
network_name=$1
expected_count=$2

# Check if the network name is provided
if [ -z "$network_name" ]; then
  echo "Please provide the name of the Docker network"
  exit 1
fi

# Check if the network name is provided
if [ -z "$expected_count" ]; then
  echo "Please provide the expected count of containers in the Docker network"
  exit 1
fi

# Check if the network exists
if ! docker network inspect "$network_name" >/dev/null 2>&1; then
  echo "No such network: '$network_name'"
  exit 1
fi

# Get the actual number of containers in the network
actual_count=$(docker network inspect "$network_name" --format='{{range $container := .Containers}}{{$container.Name}} {{end}}' | wc -w)

# Compare the actual count with the expected count
if [ "$actual_count" -ne "$expected_count" ]; then
  echo "Expected $expected_count containers in network '$network_name', but found $actual_count containers"
  exit 1
fi

# Get the list of container names in the network
container_names=$(docker network inspect "$network_name" --format '{{range $container := .Containers}}{{$container.Name}} {{end}}')

# Check if any container is not running
for container_name in $container_names; do
  if ! docker container inspect -f '{{.State.Running}}' "$container_name" > /dev/null 2>&1; then
    echo "Container '$container_name' in network '$network_name' is not running"
    exit 1
  fi
done

exit 0
