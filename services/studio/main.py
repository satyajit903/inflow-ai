from typing import List, Optional, Dict, Any
import uuid
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from .database import get_db, engine
from .models import Base, Draft, DraftStatus

app = FastAPI(title="Creator Studio Service")

# --- Pydantic Schemas ---
class DraftBase(BaseModel):
    content: Optional[Dict[str, Any]] = None

class DraftCreate(DraftBase):
    creator_id: str

class DraftUpdate(DraftBase):
    pass

class DraftResponse(DraftBase):
    id: uuid.UUID
    creator_id: str
    status: DraftStatus
    last_updated: Any # storing as datetime in DB, pydantic handles it

    class Config:
        orm_mode = True

# --- Startup Event ---
@app.on_event("startup")
async def startup():
    # In production, use migrations (Alembic). For dev prototype, create tables.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# --- Endpoints ---

@app.get("/drafts", response_model=List[DraftResponse])
async def get_drafts(creator_id: str, db: AsyncSession = Depends(get_db)):
    """
    List all drafts for a specific creator.
    """
    result = await db.execute(select(Draft).where(Draft.creator_id == creator_id))
    drafts = result.scalars().all()
    return drafts

@app.post("/drafts", response_model=DraftResponse)
async def create_draft(draft: DraftCreate, db: AsyncSession = Depends(get_db)):
    """
    Create a new draft.
    """
    new_draft = Draft(
        creator_id=draft.creator_id,
        content=draft.content,
        status=DraftStatus.DRAFT
    )
    db.add(new_draft)
    await db.commit()
    await db.refresh(new_draft)
    return new_draft

@app.put("/drafts/{draft_id}", response_model=DraftResponse)
async def update_draft(draft_id: uuid.UUID, draft_update: DraftUpdate, db: AsyncSession = Depends(get_db)):
    """
    Update the content of a draft.
    """
    result = await db.execute(select(Draft).where(Draft.id == draft_id))
    existing_draft = result.scalar_one_or_none()

    if not existing_draft:
        raise HTTPException(status_code=404, detail="Draft not found")

    if draft_update.content is not None:
        existing_draft.content = draft_update.content
    
    # Explicitly touch updated_at if needed, but onupdate=datetime.utcnow handles it usually
    # SQLA async might need explicit flush for internal logic but commit handles persistence
    
    await db.commit()
    await db.refresh(existing_draft)
    return existing_draft
