---
name: argocd
description: CoreWeave ArgoCD operations including finding applications, checking sync policies, and understanding cluster mappings
---

# ArgoCD

## Prerequisites

**Load the `teleport` skill first** before running any `tsh` or `kubectl` commands in this guide. The teleport skill contains critical safety rules including:

- Never use the default kubeconfig (`~/.kube/config`)
- Always set `KUBECONFIG` explicitly on every command
- Use full paths (e.g., `/Users/<user>/.kube/...`) instead of `$HOME`

## When to Use

- Finding which ArgoCD manages an application
- Checking sync policies and auto-sync status
- Mapping ArgoCD cluster names to Teleport names
- Debugging deployment issues with ArgoCD-managed applications

## Instance Types

CoreWeave uses two types of ArgoCD deployments:

### Akuity-managed ArgoCD

- **Indicators**: `akuity-prod` namespace with `akuity-agent` pods
- **Application storage**: Kubernetes CRDs in `argocd` namespace (can query via `kubectl get applications -n argocd`)
- **Agent**: Connects to `*.cdsvcs.akuity.cloud`

### Self-managed ArgoCD

- **Indicators**: `argocd` namespace with `argocd-*` pods
- **Application storage**: Kubernetes CRDs in cluster
- **Access**: Can query via `kubectl get applications -n argocd`

## Cluster Architecture

Each zone has multiple clusters, and ArgoCD Application CRDs live in different clusters depending on the scope:

| Teleport Cluster | ArgoCD Applications Managed | Examples |
|------------------|----------------------------|----------|
| `<zone>-internal` | Mgmt-scoped workloads | vpc-api-worker, nimbus-vpc-controller |
| `<zone>-ngcp` | Fleetops, bmaas, infrastructure | fleetops-appplane, baremetalpools |
| `<zone>-mgmt` | None (workload cluster only) | N/A |

**Key insight**: To query ArgoCD Application status for mgmt workloads (like vpc-api-worker), check the `<zone>-internal` cluster, not `<zone>-ngcp`.

```bash
# Example: Query vpc-api-worker status in us-central-08a
KUBECONFIG=/Users/<user>/.kube/us-central-08a-internal tsh kube login us-central-08a-internal
KUBECONFIG=/Users/<user>/.kube/us-central-08a-internal kubectl get applications -n argocd | grep vpc
```

### Finding Workload Clusters

**Method 1: Check deployment annotations**

```bash
KUBECONFIG=/Users/<user>/.kube/<workload-cluster> tsh kube login <workload-cluster>
KUBECONFIG=/Users/<user>/.kube/<workload-cluster> kubectl get deployment <name> -n <namespace> -o yaml | grep argocd.argoproj.io
```

Look for `argocd.argoproj.io/instance` label to get the Application name.

**Method 2: Check ArgoCD UI**

1. Find Application in UI
2. Check **Destination** field:
   - **Cluster name**: ArgoCD's name for the cluster (e.g., `us-lab-01a-internal`)
   - **Namespace**: Where resources are deployed
3. Map cluster name to Teleport (see mappings below)

## Cluster Name Mappings

ArgoCD cluster names don't always match Teleport names:

| ArgoCD Cluster Name | Teleport Cluster Name | Purpose |
|---------------------|----------------------|---------|
| `in-cluster` | Same as ArgoCD cluster | ArgoCD managing itself |
| `<zone>-internal` | `<zone>-mgmt` | Management/workload cluster |
| `<zone>-ngcp` | `<zone>-ngcp` | NGCP cluster |

**Pattern**: ArgoCD "internal" scope maps to Teleport "mgmt" clusters.

For zone-to-cluster name mappings (e.g., US-EAST-04A -> us-east-04-mgmt), see the **Zone to Cluster Mapping** table in the `teleport` skill.

## Checking Sync Policies

### Via ArgoCD UI:

1. Navigate to Application
2. Click application name -> **App Details**
3. Look for **Sync Policy** section:
   - **Auto-Sync**: If missing, auto-sync is disabled
   - **Self Heal**: If missing or false, manual changes persist
   - **Prune**: Only affects manual syncs

### Via kubectl:

```bash
KUBECONFIG=/Users/<user>/.kube/<argocd-cluster> tsh kube login <argocd-cluster>
KUBECONFIG=/Users/<user>/.kube/<argocd-cluster> kubectl get application <app-name> -n argocd -o jsonpath='{.spec.syncPolicy}' | jq .
```

## Querying Application Status

Get sync and health status:

```bash
KUBECONFIG=/Users/<user>/.kube/<argocd-cluster> kubectl get application <app-name> -n argocd -o jsonpath='{.status}' | jq '{sync: .sync.status, health: .health.status, reconciledAt: .reconciledAt}'
```

Get source configuration (chart version, image tag):

```bash
KUBECONFIG=/Users/<user>/.kube/<argocd-cluster> kubectl get application <app-name> -n argocd -o jsonpath='{.spec.source}' | jq '{chart: .chart, targetRevision: .targetRevision, repoURL: .repoURL}'
```

List all applications with status:

```bash
KUBECONFIG=/Users/<user>/.kube/<argocd-cluster> kubectl get applications -n argocd
```

## Finding the ArgoCD Cluster

**From deployment annotation:**

```bash
# Get ArgoCD instance ID from deployment (requires KUBECONFIG for the workload cluster)
KUBECONFIG=/Users/<user>/.kube/<workload-cluster> kubectl get deployment <name> -n <namespace> -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/instance}'

# Example output: vpc-api-worker-prod-mgmt
```

**Find ArgoCD cluster by scope:**

| Workload Type | ArgoCD Cluster Pattern | Example |
|---------------|------------------------|---------|
| Mgmt workloads (vpc-api, nimbus) | `<zone>-internal` | `us-central-08a-internal` |
| Fleetops/bmaas | `<zone>-ngcp` | `us-central-08a-ngcp` |

```bash
# For mgmt workloads (e.g., vpc-api-worker)
KUBECONFIG=/Users/<user>/.kube/us-central-08a-internal tsh kube login us-central-08a-internal
KUBECONFIG=/Users/<user>/.kube/us-central-08a-internal kubectl get application vpc-api-worker-prod-mgmt -n argocd

# For fleetops/infrastructure workloads
KUBECONFIG=/Users/<user>/.kube/us-central-08a-ngcp tsh kube login us-central-08a-ngcp
KUBECONFIG=/Users/<user>/.kube/us-central-08a-ngcp kubectl get applications -n argocd
```

## ArgoCD Instances

### Central ArgoCD

- **URL**: `https://argocd.int.coreweave.com/`
- **Purpose**: Manages applications across multiple zones
- **CLI access**: Supported via SSO
- **Used by**: `cloud-deploy` repo applications

### Zone-specific ArgoCD

- **Pattern**: Varies by zone (no single pattern)
- **Examples**:
  - `https://argocd.us-lab-01a.int.coreweave.com/` (us-lab-01a)
  - `https://argocd.ngcp.us-east-03.int.coreweave.com/` (us-east-03)
- **CLI access**: NOT supported (Akuity-managed, apps stored in cloud)
- **Used by**: `k8s-services` repo applications

## ArgoCD CLI

```bash
# Login to central ArgoCD (supports SSO)
argocd login argocd.int.coreweave.com --grpc-web --sso

# List applications
argocd app list

# Get application details
argocd app get <app-name>

# View source manifests
argocd app manifests <app-name>

# Check sync status
argocd app get <app-name> --output json | jq '{name: .metadata.name, sync: .status.sync.status, health: .status.health.status}'
```

## Deployment Source Repositories

Two repositories manage Kubernetes deployments:

| Repository | ArgoCD Instance | Pattern | Notes |
|------------|-----------------|---------|-------|
| `coreweave/k8s-services` | Zone-specific | Modern, hierarchical values | Most zones |
| `coreweave/cloud-deploy` | Central | Generated manifests | Legacy, us-lab-01a |

### k8s-services (Modern)

- Uses app-of-apps pattern with `argocd-app-suites/`
- Hierarchical values: `values.yaml` -> `values-base-mgmt.yaml` -> `values-base-<zone>.yaml`
- Templates use `{{ .Values.clusterSpec.zone }}` for zone-aware config

### cloud-deploy (Legacy)

- Generated manifests in `services/<service-name>/<zone>/`
- Config source: `config/services.yaml`
- Only used for specific services in us-lab-01a

## Verifying Cluster Mappings

```bash
# 1. Find destination in ArgoCD UI (e.g., "us-lab-01a-internal")

# 2. Try likely Teleport cluster names
tsh kube ls | grep us-lab-01a

# 3. Check each for the namespace
KUBECONFIG=/Users/<user>/.kube/<cluster-candidate> tsh kube login <cluster-candidate>
KUBECONFIG=/Users/<user>/.kube/<cluster-candidate> kubectl get ns <namespace-from-argocd>

# 4. Verify with deployment annotation
KUBECONFIG=/Users/<user>/.kube/<cluster-candidate> kubectl get deployment <name> -n <namespace> -o yaml | grep argocd.argoproj.io/instance
```
