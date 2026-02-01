#!/bin/bash
MAIL_ADDRESS="contact@alexbuijsweb.nl"

HOME_DIR="/home/buijs"
VERUS_DIR="$HOME_DIR/.komodo/VRSC"
VERUS_CLI_DIR="$HOME_DIR/.verus-cli"
BACKUP_DIR="$HOME_DIR/Verus/backups"

VERUS_CMD="$VERUS_CLI_DIR/verus -conf=$VERUS_DIR/VRSC.conf"
VERUSD_CMD="$VERUS_CLI_DIR/verusd -conf=$VERUS_DIR/VRSC.conf"

VERUS_CHAIN_STATUS_URL="https://insight.verus.io/api/running?q=getInfo"
LATEST_RELEASE_URL="https://api.github.com/repos/VerusCoin/VerusCoin/releases/latest"

source $(dirname $BASH_SOURCE)/functions.sh
