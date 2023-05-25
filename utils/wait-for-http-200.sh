#!/bin/bash

timeout 300 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:6711)" != "200" ]]; do sleep 5; done' || false

