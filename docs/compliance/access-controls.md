# Access Controls Documentation

> Who can access what, and how access is managed.

## Role-Based Access Control (RBAC)

| Role | Namespaces | Actions |
|------|------------|---------|
| **platform-admin** | All | Full access |
| **ml-engineer** | ml, staging | Deploy models |
| **backend-dev** | services, staging | Deploy services |
| **viewer** | All (read-only) | View dashboards |
| **oncall** | All | Incident response |

---

## Kubernetes RBAC

```yaml
# ML Engineer Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ml-engineer
  namespace: ml
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "create", "update"]
  - apiGroups: [""]
    resources: ["pods", "logs"]
    verbs: ["get", "list"]
```

---

## Service Accounts

| Service | Access | Vault Path |
|---------|--------|------------|
| ingestion | Kafka, Feature Store | `secret/services/ingestion` |
| inference | Model Registry, Features | `secret/ml/inference` |
| decision-engine | All services | `secret/services/decision` |
| llm-service | LLM API keys | `secret/prod/llm` |

---

## Production Access

| Action | Who | Approval |
|--------|-----|----------|
| View logs | All engineers | No |
| View metrics | All engineers | No |
| SSH to pods | Platform only | Logged |
| Database access | Platform only | Ticket required |
| Secret access | Platform only | Audit logged |

---

## Access Review Schedule

| Review | Frequency | Owner |
|--------|-----------|-------|
| RBAC audit | Quarterly | Platform |
| Service account rotation | Monthly | Platform |
| Human access review | Quarterly | Security |

---

## Emergency Access

For incidents only:
1. Request via PagerDuty
2. Temporary credentials (4hr TTL)
3. All actions logged
4. Post-incident review

---

## Owner

**Mohit Ranjan** (Platform)

Last reviewed: 2026-01-16
