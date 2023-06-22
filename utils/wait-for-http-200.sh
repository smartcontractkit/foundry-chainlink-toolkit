#!/bin/bash

timeout --foreground -s TERM ${2} bash -c \
  'a=1;while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' ${0})" != "200" ]]; do echo "Waiting for ${0} ($a)" && a=$(( $a + 1 )) && sleep 5; done' ${1}
RETURN_CODE="$?"
if [[ "${RETURN_CODE}" == 0 ]]; then
    echo "OK: ${1}"
elif [[ "${RETURN_CODE}" == 124 ]]; then
    echo "Timeout: ${1} -> EXIT"
    exit "${RETURN_CODE}"
else
    echo "Failed. Error code ${RETURN_CODE}: ${1} -> EXIT"
    exit "${RETURN_CODE}"
fi
