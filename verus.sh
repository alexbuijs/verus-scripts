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
SAFE_TRADE_URL="https://safe.trade/api/v2/trade/public/tickers/vrscusdt"
KRAKEN_URL="https://api.kraken.com/0/public/Ticker?pair=USDTEUR"
CMC_URL="https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest"

source $(dirname $BASH_SOURCE)/functions.sh
