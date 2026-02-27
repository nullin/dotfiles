---
name: teleport
description: >
  **REQUIRED** for ALL Teleport and remote Kubernetes operations. You MUST load this skill before:
  logging into Teleport, accessing any CoreWeave Kubernetes cluster, running kubectl against remote clusters,
  listing clusters, requesting elevated access, or mapping zone names to cluster names.
  This skill contains critical safety rules (e.g., never use default kubeconfig).
---

# Teleport

**IMPORTANT:** You MUST load this skill before performing ANY Teleport or remote Kubernetes operations. Do not attempt to run `tsh`, `kubectl` against remote clusters, or access CoreWeave infrastructure without first loading this skill.

## When to Use

Load this skill when:

- Accessing ANY Kubernetes cluster in CoreWeave environments
- Running `tsh` commands (login, kube login, status, etc.)
- Running `kubectl` against remote/production clusters
- Listing available clusters
- Requesting elevated/write access
- Mapping zone names to cluster names

## Login (Read-Only Access to All Clusters)

```bash
# Login to root Teleport cluster - gives read access to ALL K8s clusters
tsh login --proxy=teleport.na.int.coreweave.com:443 teleport

# Verify login status
tsh status

# Logout when done
tsh logout
```

**Important:** Login to the root `teleport` cluster (not a leaf cluster like `teleport.us-east-03.int.coreweave.com`) to access all Kubernetes clusters without needing `--cluster` flags.

## Accessing a Kubernetes Cluster

**IMPORTANT:** Never use the default kubeconfig (`~/.kube/config`). Always use cluster-named kubeconfig files and explicitly set `KUBECONFIG` on every command. This prevents accidentally running commands against a production cluster.

```bash
# Login to a specific K8s cluster with a cluster-named kubeconfig in ~/.kube/
# Use full path to avoid $HOME expansion issues (see bash-commands.md)
# Do not use quotes around KUBECONFIG path - it causes permission pattern matching issues
KUBECONFIG=/Users/<user>/.kube/us-lab-01a-mgmt tsh kube login us-lab-01a-mgmt

# Run kubectl commands - ALWAYS specify KUBECONFIG
KUBECONFIG=/Users/<user>/.kube/us-lab-01a-mgmt kubectl get vpcdefinitions -A
```

**Never run kubectl without KUBECONFIG** - it will use the default config which may point to a production cluster.

## Listing Clusters

```bash
# List all available K8s clusters
tsh kube ls

# List mgmt clusters only
tsh kube ls --format=json | jq -r '.[].kube_cluster_name' | grep -E '\-mgmt$'

# Search for a specific zone
tsh kube ls | grep -i lab-01a

# List available Teleport clusters (root + leaf)
tsh clusters
```

## Zone to Cluster Mapping

Zone names map to cluster names with slight variations:

| Zone | Cluster Name |
|------|-------------|
| US-LAB-01A | us-lab-01a-mgmt |
| US-EAST-04A | us-east-04-mgmt (no 'a') |
| US-EAST-02A | us-east-02-mgmt (no 'a') |
| US-EAST-03A | us-east-03-mgmt (no 'a') |
| US-WEST-03A | us-west-03-mgmt (no 'a') |
| RNO2A | rno2-mgmt (no 'a') |
| RDU1A | rdu1-mgmt (no 'a') |

**Pattern:** Most zones keep the trailing letter (e.g., us-east-06a-mgmt), but some older zones drop it.

## Requesting Elevated Access

For write access or access to restricted namespaces, request elevated access:

```bash
# Ensure you're logged in first
tsh login --proxy=teleport.na.int.coreweave.com:443 teleport

# Request access to specific resources (format: /TELEPORT_CLUSTER/namespace/K8S_CLUSTER/NAMESPACE)
tsh request create \
  --resource "/teleport.us-east-03.int.coreweave.com/namespace/us-east-03-core-zero/data-platforms-crdb-vpc-api-stg" \
  --resource "/teleport.us-lab-01a.int.coreweave.com/namespace/us-lab-01a-mgmt/vpc-api-stg-worker" \
  --roles k8s-super-admin \
  --reason "Access for vpc-api migration"
```

## Using Approved Requests

After the request is approved, activate it:

```bash
# List your requests
tsh request ls

# Show request details
tsh request show <request-id>

# If you have multiple approved requests, drop conflicting ones first
# (Teleport cannot generate certificates with multiple resource access requests)
tsh request drop <conflicting-request-id>

# Activate the approved request
tsh login --proxy=teleport.na.int.coreweave.com:443 --request-id=<request-id>
```

**Trade-off:** Elevated requests scope your access to specific resources. You may lose read access to other clusters. To restore broad read access, drop the request and re-login to root:

```bash
tsh request drop <request-id>
tsh login --proxy=teleport.na.int.coreweave.com:443 teleport
```

## Leaf Cluster Access (Alternative)

If you need to access a K8s cluster when logged into a different Teleport leaf cluster:

```bash
# Login to a specific leaf cluster
tsh login teleport.us-east-03.int.coreweave.com

# Access a K8s cluster in a DIFFERENT leaf cluster using --cluster flag
KUBECONFIG=/Users/<user>/.kube/us-lab-01a-mgmt tsh kube login us-lab-01a-mgmt --cluster=teleport.us-lab-01a.int.coreweave.com
```

This is rarely needed - prefer logging into the root `teleport` cluster for broad access.

## Notes

- **Never use the default kubeconfig** (`~/.kube/config`) - always specify `KUBECONFIG` explicitly to avoid accidentally targeting a production cluster
- Use cluster-named kubeconfig files in `~/.kube/` (e.g., `/Users/<user>/.kube/us-lab-01a-mgmt`) without quotes
- Use full paths instead of `$HOME` to avoid expansion issues (see `.claude/rules/bash-commands.md`)
- The kubeconfig file is created/updated by `tsh kube login`
- Login persists until `tsh logout` or session expires (typically 12-24 hours)
- Use `tsh status` to check current login state and remaining time
