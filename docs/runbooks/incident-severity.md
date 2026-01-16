# Incident Severity Levels

> How to classify incidents.

## Severity Matrix

| Level | Description | Impact | Response |
|-------|-------------|--------|----------|
| **SEV1** | Complete outage | All users affected | Immediate |
| **SEV2** | Major degradation | Many users affected | 15 min |
| **SEV3** | Minor issue | Some users affected | 1 hour |
| **SEV4** | No impact | Potential issue | Next business day |

---

## SEV1 - Critical

**Criteria** (any one):
- Complete service outage
- Data breach or security incident
- >50% of requests failing
- Complete LLM outage affecting business

**Response**:
- All hands on deck
- Open incident bridge immediately
- Exec notification within 30 min
- Status page updated every 15 min

---

## SEV2 - High

**Criteria** (any one):
- Single critical service down
- 10-50% of requests failing
- P99 latency >10x baseline
- Model confidence degradation >20%

**Response**:
- Primary + secondary on-call
- Incident channel opened
- Status page updated every 30 min
- Escalate if no progress in 30 min

---

## SEV3 - Medium

**Criteria** (any one):
- Single non-critical service degraded
- <10% of requests affected
- P99 latency 2-10x baseline
- Single feature broken

**Response**:
- Primary on-call handles
- Slack updates
- Fix within shift if possible

---

## SEV4 - Low

**Criteria**:
- Alert tuning needed
- Non-urgent improvement needed
- Cosmetic issues
- Documentation gaps

**Response**:
- Create ticket
- Address in next sprint
- No immediate action

---

## Examples

| Situation | Severity |
|-----------|----------|
| All APIs returning 500 | SEV1 |
| LLM service returning fallbacks | SEV3 |
| Single pod crash-looping | SEV3 |
| Database failover | SEV2 |
| Prometheus down | SEV2 |
| Dashboard loading slow | SEV4 |
| Model accuracy dropped 15% | SEV2 |

---

## Owner

**Mohit Ranjan** (Platform)
