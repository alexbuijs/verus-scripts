#!/bin/bash
function _verus_email() {
  echo -e "$2" | mail -s "[raspberry-pi] $1" $MAIL_ADDRESS
}

function _verus_info() {
  verus getinfo
}

function _verus_blocks() {
  _verus_info | jq .blocks
}

function _verus_remote_blocks() {
  local retries=5
  local delay=2
  for ((i=1; i<=retries; i++)); do
    result=$(curl -sf "$REMOTE_BLOCKS_URL")
    if [[ $? -eq 0 && "$result" =~ ^[0-9]+$ ]]; then
      echo "$result"
      return 0
    fi
    sleep $delay
  done
  return 1
}

function _verus_running() {
  pgrep -x verusd &>/dev/null
}

function _verus_available() {
  _verus_info &>/dev/null
}

function _verus_wait_for_available() {
  while ! _verus_available; do sleep 10; done
}

function _verus_stop() {
  $VERUS_CMD stop
  while _verus_running; do sleep 1; done
}

function _verus_start() {
  $VERUSD_CMD -daemon > /dev/null 2>&1
}

function _verus_start_bootstrap() {
  $VERUSD_CMD -daemon -bootstrap > /dev/null 2>&1
}

function _verus_restart() {
  _verus_stop
  _verus_start
}

function _verus_log() {
  tail -f $VERUS_DIR/debug.log
}

function _verus_self_update() {
  git -C "$(dirname $BASH_SOURCE)" pull
}

function _verus_backup() {
  "$(dirname $BASH_SOURCE)/backup.sh"
}

function _verus_bootstrap() {
  nohup $(dirname $BASH_SOURCE)/bootstrap.sh > /dev/null 2>&1 &
}

function _verus_status() {
  "$(dirname $BASH_SOURCE)/status.sh" "$@"
}

function _verus_update() {
  "$(dirname $BASH_SOURCE)/update.sh"
}
