#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

if ! _verus_running
then
  SUBJECT="verusd service is not running"
  BODY="The Verus daemon service is down! Trying a restart..."
  _verus_email "$SUBJECT" "$BODY"

  _verus_start

  exit 1
fi

if ! _verus_available
then
  SUBJECT="verusd service is not healthy"
  BODY="The Verus daemon service is not healthy!"
  _verus_email "$SUBJECT" "$BODY"

  exit 1
fi

LOCAL_BLOCKS=$(_verus_blocks)
REMOTE_BLOCKS=$(_verus_remote_blocks)

if [[ $? -ne 0 ]]
then
  SUBJECT="could not get remote blocks"
  BODY="Failed to get the number of remote blocks after 5 retries.\n\nThe local Verus blockchain has $LOCAL_BLOCKS blocks."
  _verus_email "$SUBJECT" "$BODY"

  exit 1
fi

BLOCK_DIFFERENCE=$((LOCAL_BLOCKS - REMOTE_BLOCKS))

if (( ${BLOCK_DIFFERENCE#-} > 10 ))
then
  SUBJECT="verus blockchain is out of date"
  BODY="The local Verus blockchain has $LOCAL_BLOCKS blocks. The remote Verus blockchain has $REMOTE_BLOCKS blocks."
  _verus_email "$SUBJECT" "$BODY"

  exit 1
fi

_verus_update
