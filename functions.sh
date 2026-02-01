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

function remote_blocks() {
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

function self_update() {
  git -C "$(dirname $BASH_SOURCE)" pull
}

function test() {
  echo "TEST"
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
