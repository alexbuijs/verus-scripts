#!/bin/bash
source $(dirname $BASH_SOURCE)/secrets.sh

HOME_DIR="/home/buijs"
VERUS_DIR="$HOME_DIR/.komodo/VRSC"
VERUS_CLI_DIR="$HOME_DIR/.verus-cli"
BACKUP_DIR="$HOME_DIR/Verus/backups"

VERUS_CMD="$VERUS_CLI_DIR/verus -conf=$VERUS_DIR/VRSC.conf"
VERUSD_CMD="$VERUS_CLI_DIR/verusd -conf=$VERUS_DIR/VRSC.conf"

LATEST_RELEASE_URL="https://api.github.com/repos/VerusCoin/VerusCoin/releases/latest"
REMOTE_BLOCKS_URL="https://insight.verus.io/api/getblockcount"
CMC_URL="https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest"
COINGECKO_URL="https://api.coingecko.com/api/v3/simple/price?ids=verus-coin&vs_currencies=eur,usd"

source $(dirname $BASH_SOURCE)/functions.sh
