# Disaster Recovery Runbook

> Procedures for recovering from major outages.

## Recovery Objectives

| Metric | Target | Description |
|--------|--------|-------------|
| **RPO** | 1 hour | Max data loss |
| **RTO** | 4 hours | Max downtime |

---

## Disaster Scenarios

| Scenario | Severity | Recovery Time |
|----------|----------|---------------|
| Single pod crash | Low | 2 min (auto) |
| Full service outage | Medium | 30 min |
| Database corruption | High | 2 hours |
| Region failure | Critical | 4 hours |
| Data breach | Critical | Immediate response |

---

## Backup Schedule

| Component | Frequency | Retention | Location |
|-----------|-----------|-----------|----------|
| PostgreSQL | Hourly | 30 days | S3 secondary |
| Redis | Daily | 7 days | S3 |
| MLflow artifacts | On change | Indefinite | S3 replicated |
| Kubernetes configs | On change | Git | GitHub |
| Vault secrets | Daily | 90 days | Vault secondary |

---

## Recovery Procedures

### 1. Database Recovery

```bash
# List available backups
aws s3 ls s3://inflow-backups/postgres/ --recursive | tail -10

# Restore from backup
pg_restore -h $DB_HOST -U admin -d inflow \
  s3://inflow-backups/postgres/backup_YYYYMMDD.dump
```

### 2. Model Registry Recovery

```bash
# Models are immutable in S3
aws s3 sync s3://inflow-models-backup/ s3://inflow-models/

# Verify MLflow registry
mlflow models list --name inflow-baseline
```

### 3. Kubernetes Recovery

```bash
# Restore from Git (source of truth)
git checkout main
kubectl apply -k infra/kubernetes/environments/prod

# Verify deployments
kubectl get pods -n inflow-prod
```

### 4. Secret Recovery

```bash
# Vault DR restore
vault operator raft snapshot restore /backup/vault-snapshot.snap

# Verify
vault kv list secret/prod
```

---

## Region Failover

### Pre-requisites

- [ ] Secondary region warm standby running
- [ ] DNS TTL set to 60 seconds
- [ ] Database replicated

### Failover Steps

1. **Verify primary is unreachable**
   ```bash
   curl -I https://api.inflow.ai/health
   ```

2. **Promote secondary database**
   ```bash
   aws rds promote-read-replica --db-instance-identifier inflow-secondary
   ```

3. **Update DNS**
   ```bash
   aws route53 change-resource-record-sets ...
   ```

4. **Verify new primary**
   ```bash
   curl -I https://api.inflow.ai/health
   ```

---

## Post-Recovery

1. Notify stakeholders
2. Verify data integrity
3. Create incident report
4. Update runbook if needed

---

## Owner

**Mohit Ranjan** (Platform)

Last tested: [DATE]
