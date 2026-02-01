#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

OLD_BLOCKS=$(blocks)

echo "Stopping verus daemon and starting bootstrap..."
SUBJECT="verus bootstrap starting"
BODY="Starting verus bootstrap. Current block: $OLD_BLOCKS."
email "$SUBJECT" "$BODY"

stop

$VERUSD_CMD -daemon -bootstrap > /dev/null 2>&1
wait_for_available

SUBJECT="verus has been bootstrapped"
BODY="Successfully bootstrapped verus. Previous blocks: $OLD_BLOCKS. New blocks: $(blocks)."
email "$SUBJECT" "$BODY"
