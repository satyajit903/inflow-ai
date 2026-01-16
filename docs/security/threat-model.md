# Threat Model

> Security analysis of inflow-ai attack surfaces.

## System Overview

```
External → API Gateway → Services → ML → Database
              ↓
           Keycloak (Auth)
```

---

## Threat Areas

### 1. API Surface

| Threat | Risk | Mitigation |
|--------|------|------------|
| Unauthorized access | High | Keycloak OIDC |
| Rate limiting bypass | Medium | Per-client limits |
| Injection attacks | High | Input validation |
| Data exfiltration | High | RBAC + logging |

### 2. Model Endpoints

| Threat | Risk | Mitigation |
|--------|------|------------|
| Model theft | Medium | Auth + network isolation |
| Adversarial inputs | Medium | Input validation |
| Model inversion | Low | Confidence capping |
| Poisoning (indirect) | Low | Training data validation |

### 3. Data Ingestion

| Threat | Risk | Mitigation |
|--------|------|------------|
| Malformed data | Medium | Schema validation |
| Data injection | High | Input sanitization |
| Volume attacks | Medium | Rate limiting + backpressure |

### 4. LLM Prompt Injection

| Threat | Risk | Mitigation |
|--------|------|------------|
| Prompt injection | High | Input sanitization |
| Jailbreaking | Medium | System prompts + filtering |
| Data leakage | Medium | No raw data in prompts |
| Cost attacks | Medium | Token limits |

---

## Attack Scenarios

### Scenario 1: Prompt Injection

**Attack**: User sends crafted input to LLM service
**Impact**: LLM ignores instructions, reveals internal data
**Mitigation**:
- Sanitize all user inputs
- Never include raw user data in system prompts
- Output filtering
- LLM outputs are advisory only

### Scenario 2: Model Extraction

**Attack**: Repeated queries to extract model behavior
**Impact**: Competitor replicates model
**Mitigation**:
- Rate limiting
- Confidence score rounding
- Query logging + anomaly detection

### Scenario 3: Credential Theft

**Attack**: Service credentials exposed
**Impact**: Unauthorized access
**Mitigation**:
- Vault for all secrets
- Short TTL tokens
- mTLS between services

---

## Security Controls Summary

| Control | Status | Owner |
|---------|--------|-------|
| Authentication | ✅ Keycloak | Platform |
| Authorization | ✅ RBAC | Platform |
| Encryption at rest | ✅ S3/EBS | Platform |
| Encryption in transit | ✅ mTLS | Platform |
| Secret management | ✅ Vault | Platform |
| Input validation | ✅ Services | Services |
| Rate limiting | ✅ API Gateway | Platform |
| Audit logging | ✅ All services | Platform |

---

## Open Risks

| Risk | Severity | Status |
|------|----------|--------|
| Missing WAF | Medium | P4 planned |
| No pen test | Medium | Scheduled |
| LLM jailbreak | Low | Monitored |

---

## Owner

**Mohit Ranjan** (Platform)

Last reviewed: 2026-01-16
