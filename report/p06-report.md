# CTE412 Practical 6 — Report (student 02230120)

## 1. Objective
<own words: measure, not assume, the availability impact of Recreate, RollingUpdate and blue/green releases, failed-release handling and feature flags>

## 2. Environment
- OS: 
- Docker: | kind: | kubectl: | cluster Kubernetes (`kubectl version`): 
- Application: Python 3.12 (stdlib http.server), base `python:3.12-alpine`

## 3. Results
Fill from evidence/*-summary.txt (peak Pods from t*-podwatch.txt / quota Used).

| Release | Requests observed | Failed requests | Mixed-version window (s) | Peak notice-board Pods |
|---|---|---|---|---|
| Recreate 1.0.0→1.1.0 (t5-recreate) | | | | |
| RollingUpdate 1.0.0→1.1.0 (t5-rolling) | | | | |
| Broken 1.2.0-broken (t6-broken) | | | | |
| Rollback (t6-all) | | | | |
| Blue→Green switch 1 | | | | |
| Green→Blue switch 2 | | | | |
| Blue→Green switch 3 | | | | |
| Flag change (t8-all) | | | | |

## 4. Analysis
**A1.** Rank by failed requests; mechanism (Recreate: all Pods terminated before new Ready; Rolling: maxUnavailable 0; blue/green: endpoint swap). Cite evidence/t5-recreate-monitor.log, t5-rolling-monitor.log, t7-monitor.log.

**A2.** Fields: `progressDeadlineSeconds: 60`, `maxUnavailable: 0`, `maxSurge: 1`, `minReadySeconds: 5`, readinessProbe on /healthz. The broken Pod never became Ready so the controller never removed an old Pod. Defaults (maxUnavailable 25%, maxSurge 25%, deadline 600 s) — with 3 replicas 25% rounds down to 0 unavailable, so predict: <your prediction>; with readiness removed, broken Pods would receive traffic → failures. Cite t6-broken-conditions.txt, t6-broken-pods.txt, t6-all-summary.txt.

**A3.** Compare mixed-version window, peak quota use (t5 rolling 4 Pods vs t7 quota Used 6+ Pods, evidence/t7-quota.txt), rollback time (rollout undo vs Service switch back).

**A4.** <e.g. a version that runs a DB schema migration incompatible with the old version, or a singleton holding an exclusive lock/volume, where two versions must never run together>

**A5.** Flag changed behaviour without a new image (same image 1.1.0, ConfigMap edit). It did not avoid a Pod restart: env vars from a ConfigMap are read only at container start (evidence/t8-pods-before-restart.txt), so a rolling restart was needed.

## 5. Reflection
- Error met: <command output + reasoning>
- Still unclear: <one thing>

## 6. References
- <URL, date accessed 2026-10-DD>
