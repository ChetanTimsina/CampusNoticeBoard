#!/usr/bin/env bash
# Usage: scripts/mark.sh "<label>"  -> appends a UTC timestamp marker to evidence/markers.txt
cd "$(dirname "$0")/.."; echo "$1 $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a evidence/markers.txt
