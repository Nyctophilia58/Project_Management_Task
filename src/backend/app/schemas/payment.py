from pydantic import BaseModel

class PaymentCreate(BaseModel):
    task_id: int
    amount: float
