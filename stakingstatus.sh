#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

COUNT_FILE="$HOME_DIR/Verus/txHistory.txt"

WALLET_INFO=$($VERUS_CMD getwalletinfo)
if [ $? -ne 0 ]; then exit; fi

PREVIOUS_COUNT=$(cat $COUNT_FILE 2>/dev/null || echo "")
CURRENT_COUNT=$(echo $WALLET_INFO | jq -r .txcount)

if [[ $CURRENT_COUNT != $PREVIOUS_COUNT ]]
then
  backup
  if [ $? -ne 0 ]
  then
    DOWNLOAD_INSTRUCTIONS="Backup failed!"
  else
    BACKUP_FILE="$(ls -t $BACKUP_DIR | head -1).gpg"
    DOWNLOAD_INSTRUCTIONS="Download wallet backup: aws s3 cp s3://raspberry-verus/$BACKUP_FILE"
  fi

  SUBJECT="A transaction has happened"
  BODY="A transaction occurred in your Verus wallet!\n\nCurrent wallet info:\n$WALLET_INFO\n\n$DOWNLOAD_INSTRUCTIONS"
  email "$SUBJECT" "$BODY"

  echo $CURRENT_COUNT > $COUNT_FILE
fi
