# Cost Controls Runbook

> Managing infrastructure and LLM costs.

## Cost Visibility

### Dashboards

| Dashboard | URL | Owner |
|-----------|-----|-------|
| AWS Cost Explorer | console.aws.amazon.com | Platform |
| LLM Token Usage | grafana/llm-costs | Platform |
| Per-Service Costs | grafana/service-costs | Platform |

---

## Budget Thresholds

| Component | Monthly Budget | Alert at |
|-----------|----------------|----------|
| Compute (EKS) | $5,000 | 80% |
| Storage (S3/EBS) | $1,000 | 80% |
| LLM APIs | $3,000 | 70% |
| Database | $1,000 | 80% |
| Total | $10,000 | 75% |

---

## LLM Cost Controls

### Daily Limits

```yaml
# services/llm-service/config.yaml
cost:
  daily_token_limit: 1000000
  daily_budget_usd: 100.00
  alert_threshold_percent: 80
```

### Per-Request Limits

| Limit | Value |
|-------|-------|
| Max input tokens | 4,000 |
| Max output tokens | 1,000 |
| Request timeout | 30s |

---

## Cost Attribution

| Service | Tag | Reporting |
|---------|-----|-----------|
| Ingestion | `team:platform` | Weekly |
| ML Training | `team:ml` | Per-run |
| Inference | `team:ml` | Daily |
| LLM | `team:ml` | Daily |

---

## Cost Alerts

| Alert | Threshold | Action |
|-------|-----------|--------|
| Daily LLM budget 80% | $80/day | Notify |
| Daily LLM budget 100% | $100/day | Disable LLM |
| Monthly total 90% | $9,000 | Notify VP |

---

## Cost Reduction Playbook

### Immediate Actions

1. **Disable LLM features**
   ```bash
   kubectl set env deployment/llm-service -n inflow-prod LLM_ENABLED=false
   ```

2. **Scale down non-critical replicas**
   ```bash
   kubectl scale deployment/profile-service --replicas=1
   ```

3. **Enable spot instances** (if not already)

### Long-term Actions

- Review model serving efficiency
- Cache LLM responses for common queries
- Optimize batch sizes

---

## Owner

**Mohit Ranjan** (Platform)
