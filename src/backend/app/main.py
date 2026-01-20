from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routes import auth, user, project, task, payment, admin

app = FastAPI(title="Task Platform API")

app.include_router(auth.router)
app.include_router(user.router)
app.include_router(project.router)
app.include_router(task.router)
app.include_router(payment.router)
app.include_router(admin.router)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/")
def read_root():
    return {"message": "Welcome to the Task Platform API"}
