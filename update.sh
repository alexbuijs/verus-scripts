#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

INFO=$(info); exit_1=$?
CURRENT_VERSION=v$(echo $INFO | jq -er .VRSCversion); exit_2=$?
if (( $exit_1 || $exit_2 )); then exit 1; fi

LATEST_RELEASE=$(curl -s $LATEST_RELEASE_URL); exit_1=$?
LATEST_VERSION=$(echo -E $LATEST_RELEASE | jq -er .tag_name); exit_2=$?
if (( $exit_1 || $exit_2 ))
then
  SUBJECT="verus-cli failed to get latest release"
  BODY="Failed to get the latest release of verus-cli.\n\n$(echo $LATEST_RELEASE)"
  email "$SUBJECT" "$BODY"

  exit 1
fi

if [[ $CURRENT_VERSION == $LATEST_VERSION ]]; then exit 0; fi

SUBJECT="verus-cli update available"
BODY="There is a new version of verus-cli available!\n\nGoing to update from version $CURRENT_VERSION to version $LATEST_VERSION."
email "$SUBJECT" "$BODY"

cd $HOME_DIR || exit 1
ARCHIVE_FILE="Verus-CLI-Linux-$LATEST_VERSION-arm64"
DOWNLOAD_LINK=$(echo $LATEST_RELEASE | jq -r '.assets[] | select(.name|test("Linux.*arm64")) | .browser_download_url')
wget -q $DOWNLOAD_LINK
tar xzf $ARCHIVE_FILE.tgz
SIGNATURE_FILE="$ARCHIVE_FILE.tar.gz.signature.txt"
ARCHIVE_VALID=$($VERUS_CMD verifyfile "$(cat $SIGNATURE_FILE | jq -r .signer)" "$(cat $SIGNATURE_FILE | jq -r .signature)" $HOME_DIR/$ARCHIVE_FILE.tar.gz)

if [[ $ARCHIVE_VALID != true ]]
then
  SUBJECT="verus-cli failed to update"
  BODY="Failed to update verus-cli due to invalid archive."
  email "$SUBJECT" "$BODY"

  rm $ARCHIVE_FILE*

  exit 1
fi

tar xzf $ARCHIVE_FILE.tar.gz
rm -rf $ARCHIVE_FILE*
rm -rf .verus-cli.old

stop

mv .verus-cli .verus-cli.old
mv verus-cli .verus-cli

start_and_wait

SUBJECT="verus-cli has been updated"
BODY="Successfully updated verus-cli from version $CURRENT_VERSION to version $LATEST_VERSION.\n\n$(echo $LATEST_RELEASE | jq -r .body)"
email "$SUBJECT" "$BODY"
