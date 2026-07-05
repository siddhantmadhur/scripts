#!/bin/bash

# load .env 
set -a
source /scripts/.env.public
set +a

if [[ -z "$LORE_S3_BUCKET" ]]; then
	echo "Environment variables not found, backup failed!"
	exit 1
fi

IDENTIFIER=$(openssl rand -hex 6)

FILENAME="latest_archive.tar.gz"
IDENTIFIED_FILENAME="archive_${IDENTIFIER}.tar.gz"

tar -czvf $FILENAME /opt/loreserver/store
status=$?

if [ $status -eq 0 ]; then
	echo "Generated archive: $IDENTIFIED_FILENAME..."
	aws s3 mv s3://$LORE_S3_BUCKET/$FILENAME s3://$LORE_S3_BUCKET/$IDENTIFIED_FILENAME  --storage-class DEEP_ARCHIVE
	aws s3 cp $FILENAME s3://$LORE_S3_BUCKET
	rm $FILENAME
fi

echo "Uploaded archive!"
exit 0
