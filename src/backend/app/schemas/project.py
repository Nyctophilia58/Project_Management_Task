from typing import Optional
from pydantic import BaseModel

class ProjectCreate(BaseModel):
    title: str
    description: str
    buyer_id: Optional[int] = None