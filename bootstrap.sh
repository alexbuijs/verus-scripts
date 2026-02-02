#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

OLD_BLOCKS=$(_verus_blocks)

echo "Stopping verus daemon and starting bootstrap..."
SUBJECT="verus bootstrap starting"
BODY="Starting verus bootstrap. Current block: $OLD_BLOCKS."
_verus_email "$SUBJECT" "$BODY"

_verus_stop

$VERUSD_CMD -daemon -bootstrap > /dev/null 2>&1
_verus_wait_for_available

SUBJECT="verus has been bootstrapped"
BODY="Successfully bootstrapped verus. Previous blocks: $OLD_BLOCKS. New blocks: $(_verus_blocks)."
_verus_email "$SUBJECT" "$BODY"
