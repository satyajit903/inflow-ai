from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import asyncio
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Orchestrator Service")

# --- Mock Clients ---
# In a real scenario, these would be imported from services.common.clients or similar

class ViabilityClient:
    async def check(self, idea_text: str) -> Dict[str, Any]:
        # Simulate network call
        await asyncio.sleep(0.1)
        if "fail_viability" in idea_text:
            raise Exception("Viability Service unavailable")
        return {"score": 85, "status": "viable"}

class RiskClient:
    async def scan(self, idea_text: str) -> Dict[str, Any]:
        await asyncio.sleep(0.1)
        if "fail_risk" in idea_text:
            raise Exception("Risk Service timeout")
        return {"level": "low", "flags": []}

class TimingClient:
    async def get_best_time(self) -> Dict[str, Any]:
        await asyncio.sleep(0.1)
        return {"best_post_time": "18:00 UTC", "day": "Wednesday"}

# Instantiate clients
viability_client = ViabilityClient()
risk_client = RiskClient()
timing_client = TimingClient()

# --- Schemas ---

class IdeaRequest(BaseModel):
    idea_text: str

class AnalysisResponse(BaseModel):
    viability: Dict[str, Any]
    risk: Any # Can be dict or string "UNKNOWN"
    timing: Optional[Dict[str, Any]]

# --- Endpoints ---

@app.post("/analyze-idea", response_model=AnalysisResponse)
async def analyze_idea(request: IdeaRequest):
    """
    Orchestrate calls to Viability, Risk, and Timing services to analyze an idea.
    """
    idea_text = request.idea_text
    
    # 1. Call ViabilityClient (Critical Dependency)
    try:
        viability_result = await viability_client.check(idea_text)
    except Exception as e:
        logger.error(f"Viability check failed: {e}")
        # If Viability fails, return 500 error (Critical dependency)
        raise HTTPException(status_code=500, detail="Critical dependency 'Viability' failed.")

    # 2. Call RiskClient (Non-Critical, Partial Failure)
    try:
        risk_result = await risk_client.scan(idea_text)
    except Exception as e:
        logger.error(f"Risk scan failed: {e}")
        # If Risk fails, set "risk": "UNKNOWN"
        risk_result = "UNKNOWN"

    # 3. Call TimingClient (Assuming Non-Critical for now, or just let it fail if not specified)
    # The prompt actually only specified "Risk" failure behavior explicitly, 
    # and Viability critical failure. I will treat Timing as safe to return null or error if needed,
    # but for consistent "Aggregator" behavior I'll wrap it similarly.
    try:
        timing_result = await timing_client.get_best_time()
    except Exception as e:
        logger.error(f"Timing check failed: {e}")
        timing_result = None

    return AnalysisResponse(
        viability=viability_result,
        risk=risk_result,
        timing=timing_result
    )
