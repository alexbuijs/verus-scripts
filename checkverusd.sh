#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

if ! running
then
  SUBJECT="verusd service is not running"
  BODY="The Verus daemon service is down! Trying a restart..."
  email "$SUBJECT" "$BODY"

  start

  exit 1
fi

if ! available
then
  SUBJECT="verusd service is not healthy"
  BODY="The Verus daemon service is not healthy!"
  email "$SUBJECT" "$BODY"

  exit 1
fi

LOCAL_BLOCKS=$(blocks)
REMOTE_STATUS=$(curl -s $VERUS_CHAIN_STATUS_URL); exit_1=$?
REMOTE_BLOCKS=$(echo $REMOTE_STATUS | jq -er .info.blocks); exit_2=$?
BLOCK_DIFFERENCE=$((LOCAL_BLOCKS - REMOTE_BLOCKS)); exit_3=$?

if (( $exit_1 || $exit_2 || $exit_3 ))
then
  SUBJECT="could not get remote blocks"
  BODY="Failed to get the number of remote blocks.\n\nThe local Verus blockchain has $LOCAL_BLOCKS blocks.\n\n$REMOTE_STATUS"
  email "$SUBJECT" "$BODY"

  exit 1
elif (( ${BLOCK_DIFFERENCE#-} > 10 ))
then
  SUBJECT="verus blockchain is out of date"
  BODY="The local Verus blockchain has $LOCAL_BLOCKS blocks. The remote Verus blockchain has $REMOTE_BLOCKS blocks."
  email "$SUBJECT" "$BODY"

  exit 1
fi

update
