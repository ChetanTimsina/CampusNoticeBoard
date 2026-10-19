# CTE412 Practical 6 — Campus Notice Board releases on Kubernetes (student 02230120)

Rolling / Recreate / Blue-Green releases measured with an in-cluster availability monitor.

**Versions (fill in):** Docker `docker version`, kind `kind version`, kubectl `kubectl version --client`. Base image `python:3.12-alpine`, monitor `busybox:1.36`.

## Rebuild the final state (Task 8 end state) from an empty machine
```bash
kind create cluster --config cluster/kind-cluster.yaml
scripts/build.sh                                   # build 3 images, load into kind (no registry)
kubectl apply -f manifests/base/namespace.yaml
kubectl config set-context --current --namespace=nb-02230120
kubectl apply -f manifests/base/quota-limitrange.yaml
kubectl apply -f manifests/base/monitor.yaml
kubectl apply -f manifests/bluegreen/flags.yaml -f manifests/bluegreen/blue.yaml -f manifests/bluegreen/green.yaml -f manifests/bluegreen/services.yaml
kubectl rollout status deploy/notice-board-blue deploy/notice-board-green
```
(Run the two rollout-status commands separately if your kubectl rejects the combined form.)

## Clean-up
```bash
kubectl config set-context --current --namespace=default
kind delete cluster --name cte412-02230120
```

## Layout
`cluster/` kind config · `app/` source+Dockerfile · `manifests/` base, rolling, bluegreen · `scripts/` summarise/release/slice/switch/flag helpers · `evidence/` captured output · `report/p06-report.md`
