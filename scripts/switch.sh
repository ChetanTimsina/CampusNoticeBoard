#!/usr/bin/env bash
# Usage: scripts/switch.sh <blue|green>  -> edits ACTIVE-SLOT in services.yaml, applies, marks time.
cd "$(dirname "$0")/.."; F=manifests/bluegreen/services.yaml
sed "s/^\( *slot: \)[a-z]*\( *# ACTIVE-SLOT\)/\1$1\2/" $F > $F.tmp && mv $F.tmp $F
scripts/mark.sh "SWITCH-to-$1"
kubectl apply -f $F
sleep 15   # let the monitor record steady state after each switch
