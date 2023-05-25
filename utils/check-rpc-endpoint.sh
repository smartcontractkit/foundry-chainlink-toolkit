#!/bin/bash

# Make a HTTP request to the RPC endpoint
response=$(curl -S -s "$1" -X POST -H "Content-Type: application/json" --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}')
# Check the response code
if [[ "$response" == *"\"result\":\""* ]]; then
  exit 0
else
  echo "RPC URL $1 is not accessible or didn't return the expected JSON response."
  exit 1
fi
