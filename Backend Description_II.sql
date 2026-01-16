┌───────────────────────────────────────────────────────────────────────────────┐
│                           API GATEWAY / EDGE LAYER                              │
│---------------------------------------------------------------------------------│
│ Responsibilities:                                                               │
│ • Authentication & Authorization (Creator, Team, Org, Role)                    │
│ • Session Management                                                            │
│ • Rate Limiting & Abuse Prevention                                              │
│ • Request Validation & Normalization                                            │
│ • Correlation ID Injection (for end-to-end tracing)                             │
│ • Routing to internal services                                                  │
│                                                                               │
│ Guarantees:                                                                     │
│ • No unauthenticated traffic reaches intelligence services                      │
│ • Every request is traceable end-to-end                                         │
│ • Partial failures are surfaced, not hidden                                     │
└───────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                    CONVERSATIONAL WORKSPACE SERVICE                              │
│---------------------------------------------------------------------------------│
│ Purpose:                                                                        │
│ • Accepts natural language input from creators                                  │
│ • Maintains conversation threads                                                │
│ • Does NOT make decisions                                                       │
│ • Does NOT generate content                                                     │
│                                                                               │
│ Responsibilities:                                                               │
│ • Thread creation & continuation                                                │
│ • Context stitching (conversation-level only)                                   │
│ • Delegates intent to downstream systems                                        │
│                                                                               │
│ Explicit Non-Responsibilities:                                                  │
│ • No personalization logic                                                      │
│ • No memory interpretation                                                      │
│ • No decision logic                                                             │
└───────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                        INTENT CLASSIFICATION SERVICE                             │
│---------------------------------------------------------------------------------│
│ Purpose:                                                                        │
│ • Determine what the creator is actually trying to do                           │
│                                                                               │
│ Intent Classes:                                                                 │
│ • Decision-seeking (Should / When / Risk)                                       │
│ • Creation request (Generate / Rewrite / Repurpose)                             │
│ • Planning request (Calendar / Strategy)                                        │
│ • Reflection / Learning                                                         │
│                                                                               │
│ Outputs:                                                                        │
│ • intent_type                                                                   │
│ • confidence_score                                                              │
│ • ambiguity_flags                                                               │
│                                                                               │
│ Hard Rule:                                                                      │
│ • If intent is ambiguous → ask clarification                                    │
└───────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                       CREATOR INTELLIGENCE ORCHESTRATOR                          │
│---------------------------------------------------------------------------------│
│ Purpose:                                                                        │
│ • Central coordinator for all personalization                                   │
│ • Owns creator-specific reasoning                                                │
│                                                                               │
│ Responsibilities:                                                               │
│ • Load creator identity & history                                               │
│ • Apply preferences & constraints                                               │
│ • Decide which intelligence services to invoke                                  │
│ • Merge outputs into coherent guidance                                          │
└───────────────────────────────────────────────────────────────────────────────┘
           │                     │                     │
           ▼                     ▼                     ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                        CREATOR IDENTITY GRAPH SERVICE                            │
│---------------------------------------------------------------------------------│
│ Stores & Models:                                                                │
│ • Platforms used                                                                │
│ • Content formats                                                               │
│ • Posting cadence                                                               │
│ • Topic clusters                                                                │
│ • Language & tone                                                               │
│ • Growth stage (aspiring / active / professional)                               │
│                                                                               │
│ Characteristics:                                                               │
│ • Behavioral, not declarative                                                   │
│ • Derived from usage, not just onboarding                                       │
│                                                                               │
│ Output:                                                                         │
│ • creator_profile_snapshot                                                      │
│ • confidence metadata                                                           │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                     PREFERENCE & CALIBRATION ENGINE                              │
│---------------------------------------------------------------------------------│
│ Learns From:                                                                   │
│ • Accepted vs rejected suggestions                                             │
│ • Editing depth on generated content                                           │
│ • Risk avoidance behavior                                                      │
│                                                                               │
│ Explicit Inputs (Conversational):                                               │
│ • “Be more experimental”                                                       │
│ • “Avoid controversy”                                                          │
│ • “Optimize for long-term trust”                                                │
│                                                                               │
│ Output:                                                                         │
│ • Soft constraints (never hard rules)                                           │
│ • Personalization modifiers                                                    │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                           CREATOR MEMORY SERVICE                                 │
│---------------------------------------------------------------------------------│
│ Stores:                                                                        │
│ • Past decisions                                                               │
│ • Overrides                                                                    │
│ • Reflections                                                                  │
│ • Outcome summaries (if available)                                             │
│                                                                               │
│ Properties:                                                                    │
│ • Time-aware                                                                   │
│ • Append-only                                                                  │
│ • Explainable                                                                 │
│                                                                               │
│ Output:                                                                        │
│ • Relevant memory slices for current context                                   │
└───────────────────────────────────────────────────────────────────────────────┘


┌───────────────────────────────────────────────────────────────────────────────┐
│                      DECISION INTELLIGENCE ORCHESTRATOR                          │
│---------------------------------------------------------------------------------│
│ Purpose:                                                                        │
│ • Coordinate all pre-creation reasoning                                         │
│                                                                               │
│ Hard Rule:                                                                      │
│ • Never outputs a command                                                       │
│ • Always outputs comparative guidance                                           │
└───────────────────────────────────────────────────────────────────────────────┘
           │                 │                 │                 │          │
           ▼                 ▼                 ▼                 ▼          ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                         IDEA VIABILITY ANALYZER                                  │
│---------------------------------------------------------------------------------│
│ Evaluates:                                                                     │
│ • Novelty vs repetition                                                        │
│ • Alignment with creator identity                                              │
│ • Effort vs expected payoff                                                    │
│                                                                               │
│ Output:                                                                        │
│ • Viability signals                                                            │
│ • Confidence bounds                                                            │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                      TIMING & CONTEXT INTELLIGENCE SERVICE                       │
│---------------------------------------------------------------------------------│
│ Models:                                                                        │
│ • Platform activity cycles                                                     │
│ • Event collisions (sports, launches, crises)                                  │
│ • Attention pressure                                                           │
│                                                                               │
│ Output:                                                                        │
│ • Publish-now vs delay comparisons                                             │
│ • Contextual explanation                                                       │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                    AUDIENCE FATIGUE & REDUNDANCY ENGINE                         │
│---------------------------------------------------------------------------------│
│ Detects:                                                                       │
│ • Topic overexposure                                                           │
│ • Narrative repetition                                                         │
│ • Diminishing engagement probability                                           │
│                                                                               │
│ Output:                                                                        │
│ • Fatigue warnings                                                             │
│ • Long-term audience cost signals                                              │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                       RISK & SENSITIVITY REASONER                                │
│---------------------------------------------------------------------------------│
│ Models (Coarse but Honest):                                                     │
│ • Platform enforcement risk                                                    │
│ • Brand safety                                                                 │
│ • Backlash likelihood                                                          │
│                                                                               │
│ Critical Behavior:                                                             │
│ • Emits “unknown risk” when data is weak                                       │
│                                                                               │
│ Output:                                                                        │
│ • Risk bands + explanation                                                     │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                    COUNTERFACTUAL REASONING ENGINE                               │
│---------------------------------------------------------------------------------│
│ Compares:                                                                      │
│ • Option A vs Option B                                                         │
│ • Timing variants                                                              │
│ • Platform variants                                                            │
│                                                                               │
│ Output:                                                                        │
│ • Tradeoff summaries                                                           │
│ • Dominance / equivalence signals                                              │
└───────────────────────────────────────────────────────────────────────────────┘




┌───────────────────────────────────────────────────────────────────────────────┐
│                       CONTENT STRATEGY ENGINE                                    │
│---------------------------------------------------------------------------------│
│ Responsibilities:                                                               │
│ • Theme planning                                                               │
│ • Sequencing logic                                                             │
│ • Cadence recommendations                                                      │
│                                                                               │
│ Output:                                                                         │
│ • Strategy proposals                                                           │
│ • Optional content calendars                                                   │
└───────────────────────────────────────────────────────────────────────────────┘



┌───────────────────────────────────────────────────────────────────────────────┐
│                     CONTENT GENERATION ORCHESTRATOR                              │
│---------------------------------------------------------------------------------│
│ Purpose:                                                                        │
│ • Coordinate all generation tasks                                               │
│                                                                               │
│ Constraints:                                                                    │
│ • Always conditioned on decision context                                        │
│ • Never free-form                                                              │
└───────────────────────────────────────────────────────────────────────────────┘
           │                │                │                │
           ▼                ▼                ▼                ▼
Script Generation Service

Caption & Hook Generator

Hashtag & Metadata Engine

Transcription & Repurposing Service


┌───────────────────────────────────────────────────────────────────────────────┐
│                        LEARNING & FEEDBACK PIPELINE                               │
│---------------------------------------------------------------------------------│
│ Ingests:                                                                       │
│ • Creator overrides                                                           │
│ • Manual edits                                                                │
│ • Outcome signals                                                             │
│                                                                               │
│ Improves:                                                                     │
│ • Personalization accuracy                                                     │
│ • Timing intuition                                                            │
│ • Risk alignment                                                              │
│                                                                               │
│ Strict Rule:                                                                  │
│ • Offline learning only in MVP                                                │
└───────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────┐
│                       CREATOR STUDIO & CONTROL PLANE                             │
│---------------------------------------------------------------------------------│
│ Features:                                                                       │
│ • Analytics                                                                    │
│ • Content library                                                              │
│ • Calendar view                                                               │
│ • Decision history                                                            │
│                                                                               │
│ Access Pattern:                                                               │
│ • Opt-in                                                                      │
│ • Progressive                                                                 │
└───────────────────────────────────────────────────────────────────────────────┘
