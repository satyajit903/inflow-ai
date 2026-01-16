# System Architecture Overview

> High-level architecture for knowledge transfer.

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           INFLOW AI PLATFORM                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ Kafka   │───▶│ Ingestion   │───▶│ Feature     │───▶│ Inference   │  │
│  │(Redpanda)│    │ Service     │    │ Service     │    │ Service     │  │
│  └─────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│                         │                │                    │         │
│                         ▼                ▼                    ▼         │
│                  ┌─────────────┐  ┌─────────────┐    ┌─────────────┐   │
│                  │ Feature     │  │ MLflow      │    │ Decision    │   │
│                  │ Store       │  │ Registry    │    │ Engine      │   │
│                  │ (Feast)     │  │             │    │             │   │
│                  └─────────────┘  └─────────────┘    └─────────────┘   │
│                                                             │           │
│                                                             ▼           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────┐ │
│  │ LLM         │◀───│ Profile     │◀───│ Response to caller          │ │
│  │ Service     │    │ Service     │    │                             │ │
│  │ (Advisory)  │    │ (Memory)    │    └─────────────────────────────┘ │
│  └─────────────┘    └─────────────┘                                    │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│  OBSERVABILITY: Prometheus → Grafana → Alerts                          │
│  SECURITY: Keycloak → Vault → OPA → mTLS                               │
│  CI/CD: GitHub Actions → Promote Workflow                              │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

1. **Events** arrive via Kafka
2. **Ingestion** validates and normalizes
3. **Features** looked up from Feast
4. **Inference** runs XGBoost model
5. **Decision engine** applies business rules
6. **LLM** (optional) adds explanations
7. **Response** returned with audit trail

---

## Key Components

| Component | Technology | Port | Owner |
|-----------|------------|------|-------|
| Ingestion | Python/FastAPI | 8000 | Platform |
| Features | Python/FastAPI | 8002 | Services |
| Inference | Python/FastAPI | 8001 | ML |
| Decision | Python/FastAPI | 8003 | Services |
| LLM | Python/FastAPI | 8004 | ML |
| Profile | Python/FastAPI | 8005 | Services |

---

## Infrastructure

| Component | Technology | Environment |
|-----------|------------|-------------|
| Orchestration | Kubernetes (EKS) | All |
| Streaming | Redpanda | All |
| Feature Store | Feast | All |
| Model Registry | MLflow | All |
| Secrets | HashiCorp Vault | All |
| Auth | Keycloak | Staging/Prod |
| Monitoring | Prometheus + Grafana | All |

---

## Key Files

| Purpose | Path |
|---------|------|
| CI Pipeline | `.github/workflows/ci.yaml` |
| Promotion | `.github/workflows/promote.yaml` |
| K8s Base | `infra/kubernetes/base/` |
| Environments | `infra/kubernetes/environments/` |
| Services | `services/*/` |
| ML | `ml/` |
| Runbooks | `docs/runbooks/` |

---

## Owner

**Mohit Ranjan** (Platform)
