#!/bin/bash
function _verus_email() {
  echo -e "$2" | mail -s "[raspberry-pi] $1" $MAIL_ADDRESS
}

function _verus_info() {
  $VERUS_CMD getinfo
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

function _verus_restart() {
  _verus_stop
  _verus_start
}

function _verus_start_and_wait() {
  _verus_start
  _verus_wait_for_available
}

function _verus_backup() {
  "$(dirname $BASH_SOURCE)/backupwallet.sh"
}

function _verus_update() {
  "$(dirname $BASH_SOURCE)/update.sh"
}

function _verus_bootstrap() {
  nohup $(dirname $BASH_SOURCE)/bootstrap.sh > /dev/null 2>&1 &
}

function _verus_self_update() {
  git -C "$(dirname $BASH_SOURCE)" pull
}

function _verus_log() {
  tail -f $VERUS_DIR/debug.log
}

function verus() {
  local cmd="$1"
  shift

  case "$cmd" in
    email)           _verus_email "$@" ;;
    info)            _verus_info "$@" ;;
    blocks)          _verus_blocks "$@" ;;
    remote_blocks)   _verus_remote_blocks "$@" ;;
    running)         _verus_running "$@" ;;
    available)       _verus_available "$@" ;;
    wait)            _verus_wait_for_available "$@" ;;
    stop)            _verus_stop "$@" ;;
    start)           _verus_start "$@" ;;
    restart)         _verus_restart "$@" ;;
    start_and_wait)  _verus_start_and_wait "$@" ;;
    backup)          _verus_backup "$@" ;;
    update)          _verus_update "$@" ;;
    bootstrap)       _verus_bootstrap "$@" ;;
    self_update)     _verus_self_update "$@" ;;
    log)             _verus_log "$@" ;;
    *)               $VERUS_CMD "$cmd" "$@" ;;
  esac
}
