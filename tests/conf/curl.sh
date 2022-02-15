#!/usr/bin/env bash

function log {
  echo $1 >> /var/log/curl-test.log
}

log "Begin Test"

TEST_CMD="curl ${BACKEND_ADDRESS}"
log "Running $TEST_CMD"

TEST_OUT=$($TEST_CMD)
log $TEST_OUT

log "End Test"

sleep 1000
#tail -f /dev/null

