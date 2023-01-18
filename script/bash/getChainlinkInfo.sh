#!/bin/bash
docker exec "$1" chainlink keys eth list 2> /dev/null
