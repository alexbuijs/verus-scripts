#!/bin/bash
function email() {
  echo -e "$2" | mail -s "[raspberry-pi] $1" $MAIL_ADDRESS
}

function info() {
  $VERUS_CMD getinfo
}

function blocks() {
  info | jq .blocks
}

function running() {
  pgrep -x verusd &>/dev/null
}

function available() {
  info &>/dev/null
}

function wait_for_available() {
  while ! available; do sleep 10; done
}

function stop() {
  $VERUS_CMD stop
  while running; do sleep 1; done
}

function start() {
  $VERUSD_CMD -daemon > /dev/null 2>&1
}

function restart() {
  stop
  start
}

function start_and_wait() {
  start
  wait_for_available
}

function backup() {
  "$(dirname $BASH_SOURCE)/backupwallet.sh"
}

function update() {
  "$(dirname $BASH_SOURCE)/update.sh"
}

function bootstrap() {
  nohup $(dirname $BASH_SOURCE)/bootstrap.sh > /dev/null 2>&1 &
}

command_not_found_handle() {
  local script="$(dirname $BASH_SOURCE)/$1.sh"
  if [[ -f "$script" ]]; then
    shift
    "$script" "$@"
  else
    $VERUS_CMD "$@"
  fi
}
