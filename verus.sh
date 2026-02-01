#!/bin/bash
MAIL_ADDRESS="contact@alexbuijsweb.nl"

HOME_DIR="/home/buijs"
VERUS_DIR="$HOME_DIR/.komodo/VRSC"
VERUS_CLI_DIR="$HOME_DIR/.verus-cli"
BACKUP_DIR="$HOME_DIR/Verus/backups"

VERUS_CMD="$VERUS_CLI_DIR/verus -conf=$VERUS_DIR/VRSC.conf"
VERUSD_CMD="$VERUS_CLI_DIR/verusd -conf=$VERUS_DIR/VRSC.conf"

LATEST_RELEASE_URL="https://api.github.com/repos/VerusCoin/VerusCoin/releases/latest"
REMOTE_BLOCKS_URL="https://insight.verus.io/api/getblockcount"

source $(dirname $BASH_SOURCE)/functions.sh
