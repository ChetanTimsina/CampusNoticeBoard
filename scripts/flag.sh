#!/usr/bin/env bash
# Usage: scripts/flag.sh enable | true | restart   (declarative edits to manifests, then apply)
cd "$(dirname "$0")/.."; G=manifests/bluegreen/green.yaml; C=manifests/bluegreen/flags.yaml
case $1 in
 enable)  sed 's/#FLAG#//' $G > $G.tmp && mv $G.tmp $G; kubectl apply -f $C -f $G ;;
 true)    sed 's/FEATURE_PINNED: "false"/FEATURE_PINNED: "true"/' $C > $C.tmp && mv $C.tmp $C; kubectl apply -f $C ;;
 restart) sed 's/flags-revision: "1"/flags-revision: "2"/' $G > $G.tmp && mv $G.tmp $G; kubectl apply -f $G ;;
esac
