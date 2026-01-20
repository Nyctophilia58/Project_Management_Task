from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: str
    password: str
    role: str

class UserOut(BaseModel):
    id: int
    email: str
    role: str

    class Config:
        orm_mode = True
