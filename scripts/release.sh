#!/usr/bin/env bash
# Render manifests/rolling/deployment.yaml, apply it, capture monitor slice, summary, pod watch, history.
# Usage: scripts/release.sh <tag> <Recreate|RollingUpdate> <image-version> "<change-cause>" [progressDeadlineSeconds=600]
# Example: scripts/release.sh t5-recreate Recreate 1.1.0 "Recreate release of 1.1.0"
set -u; cd "$(dirname "$0")/.."; SID=02230120
TAG=$1; STRAT=$2; VER=$3; CAUSE=$4; DL=${5:-600}
now(){ date -u +%Y-%m-%dT%H:%M:%SZ; }
if [ "$STRAT" = Recreate ]; then
STRATBLOCK="  strategy:
    type: Recreate   # kill every old Pod first, then start new ones (downtime accepted)"
MRS=""
else
STRATBLOCK="  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0   # never remove a Ready Pod before a replacement is Ready
      maxSurge: 1         # at most one extra Pod during the rollout (quota-friendly)"
MRS="  minReadySeconds: 5  # new Pod must stay Ready 5 s before it counts as available"
fi
cat > manifests/rolling/deployment.yaml <<YAML
# Purpose: notice-board Deployment (single-Deployment releases, Tasks 3,5,6). Rendered by scripts/release.sh.
# Apply: kubectl apply -f manifests/rolling/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notice-board
  namespace: nb-$SID
  labels: {app: notice-board}
  annotations:
    kubernetes.io/change-cause: "$CAUSE"   # recorded in rollout history
spec:
  replicas: 3                     # lab-mandated
  progressDeadlineSeconds: $DL    # rollout with no progress for this long is marked failed
$MRS
$STRATBLOCK
  selector:
    matchLabels: {app: notice-board}   # selector is immutable, so it does not contain version
  template:
    metadata:
      labels:
        app: notice-board
        version: "$VER"           # label = image version
    spec:
      containers:
        - name: app
          image: notice-board:$SID-$VER
          imagePullPolicy: Never   # kubelet can never attempt a registry pull
          ports:
            - {name: http, containerPort: 8080}   # named port used by Services
          securityContext: {runAsNonRoot: true, allowPrivilegeEscalation: false}  # image runs as uid 10001
          resources:
            requests: {cpu: 100m, memory: 64Mi}   # 7 app Pods x 100m = 0.7 CPU fits quota 1 with monitor
            limits:   {cpu: 200m, memory: 128Mi}  # 7 x 200m = 1.4 CPU < quota 2
          readinessProbe:
            httpGet: {path: /healthz, port: http}
            periodSeconds: 2           # fast detection of readiness
          livenessProbe:
            httpGet: {path: /version, port: http}  # NOT /healthz: the broken image fails /healthz forever; using it would crash-loop Pods instead of testing the rollout
            initialDelaySeconds: 10
            periodSeconds: 10
YAML
mkdir -p evidence; T0=$(now); echo "$TAG T0=$T0 strategy=$STRAT version=$VER" >> evidence/markers.txt
sleep 10                                   # >=10 s of pre-apply monitor log
kubectl get pods -l app=notice-board -o wide -w > evidence/$TAG-podwatch.txt 2>&1 & WP=$!
echo "$TAG APPLY=$(now)" | tee -a evidence/markers.txt
kubectl apply -f manifests/rolling/deployment.yaml
timeout $((DL+40)) kubectl rollout status deploy/notice-board --timeout=$((DL+30))s 2>&1 | tee evidence/$TAG-rollout-status.txt
sleep 10; T1=$(now); kill $WP 2>/dev/null
echo "$TAG T1=$T1" >> evidence/markers.txt
kubectl logs monitor | awk -v s="$T0" -v e="$T1" '$1>=s && $1<=e' > evidence/$TAG-monitor.log
scripts/summarise.sh evidence/$TAG-monitor.log | tee evidence/$TAG-summary.txt
kubectl rollout history deploy/notice-board > evidence/$TAG-history.txt
kubectl get deploy notice-board -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\t"}{.message}{"\n"}{end}' > evidence/$TAG-conditions.txt
kubectl get pods -l app=notice-board -L version -o wide > evidence/$TAG-pods.txt
echo "Window start (use for scripts/slice.sh on multi-step tasks): $T0"
