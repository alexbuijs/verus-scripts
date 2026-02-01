#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

FILE_NAME="$BACKUP_DIR/veruswallet_`date +%Y%m%dT%H%M%S`.tar.gz"

# Create wallet export and backup
rm -f $VERUS_DIR/veruswalletexport $VERUS_DIR/veruswalletbackup
$VERUS_CMD z_exportwallet veruswalletexport
$VERUS_CMD backupwallet veruswalletbackup

# Compress and encrypt wallet
tar -czf $FILE_NAME -C $VERUS_DIR/ veruswalletbackup veruswalletexport
gpg --encrypt --recipient $MAIL_ADDRESS --trust-model always $FILE_NAME

# Upload encrypted wallet to S3
$HOME_DIR/.local/bin/aws s3 cp "${FILE_NAME}.gpg" s3://raspberry-verus/
RESULT=$?

# Remove the export, backup, encrypted file and all but the latest 3 archived wallets
rm -f $VERUS_DIR/veruswalletexport $VERUS_DIR/veruswalletbackup
rm "${FILE_NAME}.gpg"
ls -d $BACKUP_DIR/* 2>/dev/null | sort -nr | tail -n +4 | xargs -d "\n" -I {} rm {}

exit $RESULT
