#!/usr/bin/env bash
# Usage: scripts/slice.sh <tag> <start-ISO> [end-ISO=now]  -> evidence/<tag>-monitor.log and -summary.txt
cd "$(dirname "$0")/.."; E=${3:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}
kubectl logs monitor | awk -v s="$2" -v e="$E" '$1>=s && $1<=e' > evidence/$1-monitor.log
scripts/summarise.sh evidence/$1-monitor.log | tee evidence/$1-summary.txt
