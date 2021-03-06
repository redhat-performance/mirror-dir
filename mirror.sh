#!/bin/bash

function log() {
    echo "$( date --utc -Iseconds ) LOG: $@" >&2
}

set -e

type -p wget >/dev/null || exit 1
type -p rdfind >/dev/null || exit 1
type -p find >/dev/null || exit 1

[[ -z $STORAGE_DIR ]] && exit 1
[[ ! -d $STORAGE_DIR ]] && exit 1

if [[ $SKIP_AGE_CHECK == 'true' ]]; then
    log "Not checking when last backup happened"
else
    log "Checking when last backup happened"
    newest_file="$( ls -At1 $STORAGE_DIR/*.log | head -n 1 )"
    newest_file_age_days=$(( ($( date --utc +%s ) - $( date --utc +%s -r $newest_file )) / (3600*24) ))
    if [[ $newest_file_age_days -lt 6 ]]; then
        log "Newest log file $newest_file is only $newest_file_age_days days old, so skipping backup"
        exit 0
    fi
fi

MARKER="$( date --utc -Iseconds | sed 's/[^0-9a-zA-Z_-]/_/g' )"
TARGET_DIR="$STORAGE_DIR/$MARKER"
log "Target directory to mirror to: $TARGET_DIR"

for HTTP_DIR in $HTTP_DIRS; do
    [[ -z $HTTP_DIR ]] && continue
    [[ $HTTP_DIR != http* ]] && continue

    log "HTTP directory to mirror: $HTTP_DIR"

    log "Creating target directory"
    mkdir "$TARGET_DIR"

    log "Mirroring"
    wget --recursive --level 10 --no-verbose -e robots=off --no-parent --directory-prefix "$TARGET_DIR" "$HTTP_DIR" &>"$STORAGE_DIR/mirroring-$MARKER.log"

    log "Removing index.html files"
    find "$TARGET_DIR" -type f -name 'index.html*' -delete
done

log "Deduplicating"
rdfind -makehardlinks true -removeidentinode true "$STORAGE_DIR" &>"$STORAGE_DIR/deduplication-$MARKER.log"

log "Pruning"
find "$STORAGE_DIR" -type f -mtime +365 -delete
find "$STORAGE_DIR" -type d -empty -delete

log "Done"
