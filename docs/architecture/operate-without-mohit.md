# How to Operate Without Mohit

> Bus-factor reduction guide. Everything you need to run the platform.

## Critical Knowledge

### 1. Infrastructure Access

| System | How to Access | Credentials |
|--------|---------------|-------------|
| AWS Console | SSO via Okta | Your Okta login |
| Kubernetes | `aws eks update-kubeconfig` | AWS creds |
| Vault | `vault login -method=oidc` | Keycloak |
| MLflow | https://mlflow.inflow.ai | Keycloak |
| Grafana | https://grafana.inflow.ai | Keycloak |

### 2. Common Operations

| Task | Command/Procedure |
|------|-------------------|
| Deploy to staging | Merge to `develop` |
| Deploy to prod | Tag release + `promote.yaml` |
| Rollback | `kubectl rollout undo` |
| Scale up | `kubectl scale deployment/X --replicas=N` |
| Check logs | `kubectl logs -f deployment/X` |

---

## Runbook Map

| Situation | Runbook |
|-----------|---------|
| Service down | [incident-response.md](../runbooks/incident-response.md) |
| LLM issues | [llm-disable.md](../runbooks/llm-disable.md) |
| Traffic spike | [traffic-surge.md](../runbooks/traffic-surge.md) |
| Disaster recovery | [disaster-recovery.md](../runbooks/disaster-recovery.md) |
| Model rollback | [rollback.md](../runbooks/rollback.md) |
| Cost issues | [cost-controls.md](../runbooks/cost-controls.md) |

---

## Architecture Quick Reference

```
services/
├── ingestion/      # Kafka consumer (Port 8000)
├── feature-service/ # Feature lookup (Port 8002)
├── inference-service/ # ML predictions (Port 8001)
├── decision-engine/ # Business rules (Port 8003)
├── llm-service/    # Advisory AI (Port 8004)
├── profile-service/ # User memory (Port 8005)
└── common/         # Shared code

infra/
├── kubernetes/     # K8s manifests
│   ├── environments/dev/
│   ├── environments/staging/
│   └── environments/prod/
├── observability/  # Prometheus, Grafana
└── security/       # Keycloak, Vault, OPA
```

---

## Emergency Contacts

| Role | Contact | When |
|------|---------|------|
| Platform Backup | [Backup Engineer] | Platform issues |
| ML Backup | Richa | Model issues |
| Services Backup | Satyajit | API issues |
| VP Engineering | [VP] | Escalations |

---

## Things Mohit Usually Checks

1. **Daily**
   - Grafana dashboards (latency, errors)
   - Cost reports
   - Alert volume

2. **Weekly**
   - Security scan results
   - Capacity planning
   - Dependency updates

3. **Monthly**
   - RBAC review
   - Runbook updates
   - Architecture review

---

## You'll Be Fine

- All knowledge is in this repo
- All secrets are in Vault
- All configs are in Git
- All procedures are in runbooks
- Escalate if unsure

---

## Owner (for now)

**Mohit Ranjan** (Platform)

*This document exists so it doesn't have to be me.*
