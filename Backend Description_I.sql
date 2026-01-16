[ SERVICE ]          = Deployable backend service
( MODULE )           = Internal module / logic unit
{ STORE }            = Persistent storage
-->                  = Request / data flow
==>                  = Asynchronous / event flow
[!!]                 = Hard constraint / rule



┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   EDGE / CONTROL PLANE                               │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  [ API GATEWAY SERVICE ]                                                            │
│  ---------------------------------------------------------------------------------  │
│  Responsibilities:                                                                  │
│  - Authentication (User, Creator, Team, Org)                                       │
│  - Authorization (Role, Scope, Feature Access)                                     │
│  - Session lifecycle                                                               │
│  - Request validation & schema enforcement                                         │
│  - Rate limiting, abuse detection                                                  │
│  - Correlation ID injection                                                        │
│                                                                                     │
│  [!!] No request reaches intelligence services without a correlation_id             │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        CONVERSATIONAL WORKSPACE SERVICE                              │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Purpose:                                                                           │
│  - Accept natural language input                                                   │
│  - Maintain conversation threads                                                   │
│  - Forward intent to intelligence layers                                           │
│                                                                                     │
│  Explicit Non-Responsibilities:                                                     │
│  - No personalization logic                                                        │
│  - No decision making                                                              │
│  - No content generation                                                           │
│                                                                                     │
│  Internal Modules:                                                                  │
│    ( Conversation Thread Manager )                                                  │
│    ( Context Stitcher – thread-level only )                                         │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         INTENT CLASSIFICATION SERVICE                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Input:                                                                            │
│  - Raw user message                                                                │
│  - Conversation context                                                           │
│                                                                                     │
│  Internal Modules:                                                                 │
│    ( Intent Classifier )                                                           │
│    ( Ambiguity Detector )                                                          │
│                                                                                     │
│  Output:                                                                           │
│  - intent_type:                                                                   │
│      • DECISION_REQUEST                                                           │
│      • CREATION_REQUEST                                                           │
│      • PLANNING_REQUEST                                                            │
│      • REFLECTION_REQUEST                                                          │
│  - confidence                                                                      │
│  - needs_clarification (boolean)                                                   │
│                                                                                     │
│  [!!] If needs_clarification = true → system MUST ask follow-up question            │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        CREATOR INTELLIGENCE ORCHESTRATOR                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Purpose:                                                                           │
│  - Act as the single brain coordinating all AI reasoning                            │
│  - Apply creator-specific context to every decision                                 │
│                                                                                     │
│  Responsibilities:                                                                 │
│  - Load creator profile                                                            │
│  - Apply preferences                                                              │
│  - Fetch relevant memory                                                           │
│  - Decide which downstream intelligence to invoke                                   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
        │                        │                         │
        ▼                        ▼                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          CREATOR IDENTITY GRAPH SERVICE                              │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Models:                                                                           │
│  - Platforms used                                                                  │
│  - Content formats                                                                │
│  - Posting cadence                                                                │
│  - Topic clusters                                                                 │
│  - Language & tone                                                                │
│  - Growth stage                                                                   │
│                                                                                     │
│  Data Source:                                                                      │
│  - Usage behavior                                                                 │
│  - Historical actions                                                             │
│                                                                                     │
│  Output:                                                                           │
│  - creator_identity_snapshot                                                       │
│  - confidence                                                                     │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                       PREFERENCE & CALIBRATION ENGINE                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Learns From:                                                                      │
│  - Accept / reject signals                                                         │
│  - Editing depth                                                                  │
│  - Risk avoidance behavior                                                         │
│                                                                                     │
│  Explicit Inputs:                                                                  │
│  - Conversational preference statements                                            │
│                                                                                     │
│  Output:                                                                           │
│  - Soft constraints                                                               │
│  - Personalization modifiers                                                       │
│                                                                                     │
│  [!!] Preferences are never hard rules                                             │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                             CREATOR MEMORY SERVICE                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Stores:                                                                           │
│  - Past decisions                                                                 │
│  - Overrides                                                                      │
│  - Reflections                                                                    │
│  - Outcome summaries                                                              │
│                                                                                     │
│  Properties:                                                                      │
│  - Append-only                                                                    │
│  - Time-aware                                                                     │
│  - Inspectable                                                                    │
│                                                                                     │
│  Output:                                                                           │
│  - context-relevant memory slices                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        DECISION INTELLIGENCE ORCHESTRATOR                            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Purpose:                                                                           │
│  - Coordinate all pre-creation reasoning                                           │
│                                                                                     │
│  [!!] Outputs are always comparative, never prescriptive                            │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
     │             │             │              │               │
     ▼             ▼             ▼              ▼               ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           IDEA VIABILITY ANALYZER                                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Evaluates:                                                                        │
│  - Novelty vs repetition                                                          │
│  - Alignment with creator identity                                                │
│  - Effort vs payoff                                                               │
│                                                                                     │
│  Output:                                                                           │
│  - Viability signals                                                              │
│  - Confidence bounds                                                              │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                       TIMING & CONTEXT INTELLIGENCE SERVICE                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Models:                                                                           │
│  - Platform activity cycles                                                       │
│  - Event collisions                                                               │
│  - Attention pressure                                                             │
│                                                                                     │
│  Output:                                                                           │
│  - Publish-now vs delay comparisons                                               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                      AUDIENCE FATIGUE & REDUNDANCY ENGINE                            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Detects:                                                                          │
│  - Topic saturation                                                               │
│  - Narrative repetition                                                           │
│                                                                                     │
│  Output:                                                                           │
│  - Fatigue warnings                                                               │
│  - Long-term audience cost                                                        │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        RISK & SENSITIVITY REASONER                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Models (Coarse):                                                                  │
│  - Platform enforcement risk                                                      │
│  - Brand / backlash risk                                                          │
│                                                                                     │
│  [!!] If confidence is low → emit UNKNOWN_RISK                                     │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                     COUNTERFACTUAL REASONING ENGINE                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Compares:                                                                         │
│  - Option A vs B                                                                  │
│  - Timing variants                                                               │
│  - Platform variants                                                             │
│                                                                                     │
│  Output:                                                                           │
│  - Tradeoff explanations                                                         │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            CONTENT STRATEGY ENGINE                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Responsibilities:                                                                 │
│  - Theme planning                                                                │
│  - Sequencing                                                                    │
│  - Cadence                                                                       │
│                                                                                     │
│  Output:                                                                           │
│  - Strategy proposals                                                           │
│  - Optional calendars                                                           │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        CONTENT GENERATION ORCHESTRATOR                               │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Constraint:                                                                       │
│  - Must receive decision context                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
     │            │              │              │
     ▼            ▼              ▼              ▼
[ SCRIPT GENERATION SERVICE ]
[ CAPTION & HOOK GENERATOR ]
[ HASHTAG & METADATA ENGINE ]
[ TRANSCRIPTION / REPURPOSING SERVICE ]


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        LEARNING & FEEDBACK PIPELINE                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Inputs:                                                                           │
│  - Overrides                                                                      │
│  - Manual edits                                                                  │
│  - Reflections                                                                  │
│                                                                                     │
│  Updates:                                                                          │
│  - Personalization weights                                                       │
│  - Heuristic tuning                                                             │
│                                                                                     │
│  [!!] No real-time retraining in MVP                                               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         CREATOR STUDIO & ANALYTICS                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Features:                                                                         │
│  - Content library                                                               │
│  - Calendar                                                                     │
│  - Decision history                                                             │
│                                                                                     │
│  Access:                                                                           │
│  - Optional                                                                      │
│  - Progressive                                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
