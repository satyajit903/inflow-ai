# On-Call Runbook

> How to be an effective on-call engineer.

## On-Call Rotation

| Week | Primary | Secondary |
|------|---------|-----------|
| Week 1 | Platform | ML |
| Week 2 | Services | Platform |
| Week 3 | ML | Services |
| Week 4 | Platform | ML |

---

## Responsibilities

### Primary On-Call

- Respond to pages within 15 min
- Assess severity
- Coordinate incident response
- Update status page

### Secondary On-Call

- Backup if primary unavailable
- Available for escalation
- Domain expertise

---

## Tools & Access

| Tool | Purpose | Access |
|------|---------|--------|
| PagerDuty | Alerting | All on-call |
| Grafana | Monitoring | All |
| kubectl | Debugging | Platform |
| MLflow | Model info | ML |
| Slack #incidents | Communication | All |

---

## Response Checklist

### When Paged

1. [ ] Acknowledge within 5 min
2. [ ] Open incident channel if SEV1/SEV2
3. [ ] Check dashboards
4. [ ] Assess severity
5. [ ] Start mitigation
6. [ ] Communicate status

### Quick Diagnostics

```bash
# Check all pods
kubectl get pods -n inflow-prod

# Check recent events
kubectl get events -n inflow-prod --sort-by='.lastTimestamp' | tail -20

# Check logs
kubectl logs -n inflow-prod deployment/inference-service --tail=100
```

---

## Handoff

### Start of Rotation

- [ ] Review open incidents
- [ ] Check ongoing changes
- [ ] Verify access works
- [ ] Confirm secondary contact

### End of Rotation

- [ ] Brief incoming on-call
- [ ] Document unresolved issues
- [ ] Update runbooks if needed

---

## Self-Care

- You're not expected to fix everything alone
- Escalate if stuck after 30 min
- Take breaks during long incidents
- Blameless culture applies

---

## Owner

**Mohit Ranjan** (Platform)
