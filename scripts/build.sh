#!/usr/bin/env bash
# Build the three images + load them (and busybox) into the kind cluster. No registry push.
set -e; cd "$(dirname "$0")/.."; SID=02230120; C=cte412-$SID
docker build --build-arg APP_VERSION=1.0.0 --build-arg BROKEN=false -t notice-board:$SID-1.0.0 app/
docker build --build-arg APP_VERSION=1.1.0 --build-arg BROKEN=false -t notice-board:$SID-1.1.0 app/
docker build --build-arg APP_VERSION=1.2.0-broken --build-arg BROKEN=true -t notice-board:$SID-1.2.0-broken app/
docker pull busybox:1.36
for i in notice-board:$SID-1.0.0 notice-board:$SID-1.1.0 notice-board:$SID-1.2.0-broken busybox:1.36; do
  kind load docker-image $i --name $C
done
