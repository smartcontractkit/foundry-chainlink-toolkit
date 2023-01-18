#!/bin/bash
docker exec "$1" chainlink admin login -f /chainlink/chainlink_api_credentials 2> /dev/null
