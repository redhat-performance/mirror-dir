#!/bin/sh

set -xe

rm -rf storage_dir/
mkdir -p storage_dir/
export STORAGE_DIR=storage_dir
export HTTP_DIRS=http://nightlies.testing.ansible.com/ansible-tower_nightlies_m8u16fz56qr6q7/nightly_ng_2.2.0/cli/

df $STORAGE_DIR
bash ./mirror.sh || exit 1
df $STORAGE_DIR
bash ./mirror.sh || exit 1
df $STORAGE_DIR

echo "SUCCESS"
