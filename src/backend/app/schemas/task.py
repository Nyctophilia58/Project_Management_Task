from pydantic import BaseModel

class TaskCreate(BaseModel):
    project_id: int
    developer_id: int
    title: str
    description: str
    hourly_rate: int
