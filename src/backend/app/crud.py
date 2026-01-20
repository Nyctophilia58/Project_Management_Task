from sqlalchemy.orm import Session
from app.models import User, Project, Task, Payment
from app.schemas import UserCreate, ProjectCreate, TaskCreate, PaymentCreate
from app.auth import hash_password

# USERS
def create_user(db: Session, user: UserCreate):
    db_user = User(email=user.email, role=user.role, hashed_password=hash_password(user.password))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

# PROJECTS
def create_project(db: Session, project: ProjectCreate):
    db_project = Project(**project.dict())
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

# TASKS
def create_task(db: Session, task: TaskCreate):
    db_task = Task(**task.dict(), status="todo")
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

# PAYMENTS
def create_payment(db: Session, payment: PaymentCreate):
    db_payment = Payment(**payment.dict())
    db.add(db_payment)
    db.commit()
    db.refresh(db_payment)
    return db_payment
