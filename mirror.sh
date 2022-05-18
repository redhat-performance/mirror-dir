#!/bin/bash

set -e

type -p wget || exit 1
type -p rdfind || exit 1
type -p find || exit 1

[[ -z $STORAGE_DIR ]] && exit 1
[[ ! -d $STORAGE_DIR ]] && exit 1

MARKER="$( date --utc -Iseconds | sed 's/[^0-9a-zA-Z_-]/_/g' )"
TARGET_DIR="$STORAGE_DIR/$MARKER"

for HTTP_DIR in "$HTTP_DIRS"; do
    [[ -z $HTTP_DIR ]] && continue
    [[ $HTTP_DIR != http* ]] && continue

    echo "INFO: HTTP directory to mirror: $HTTP_DIR"
    echo "INFO: Target directory to mirror to: $TARGET_DIR"

    echo "DEBUG: Creating target directory"
    mkdir "$TARGET_DIR"

    echo "DEBUG: Mirroring"
    wget --recursive --level 10 -e robots=off --no-parent --directory-prefix "$TARGET_DIR" "$HTTP_DIR" &>"$STORAGE_DIR/mirroring-$MARKER.log"
done

echo "DEBUG: Deduplicating"
rdfind -makehardlinks true -removeidentinode true "$STORAGE_DIR" &>"$STORAGE_DIR/deduplication-$MARKER.log"

echo "DEBUG: Pruning"
find "$STORAGE_DIR" -type f -mtime +365 -delete
find "$STORAGE_DIR" -type d -empty -delete
