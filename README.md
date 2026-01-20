# TaskForge - Flutter Based Task Management Platform

A full-stack task management system built with Flutter (Android), FastAPI and PostgreSQL, featuring role-based access control, secure task submission, payment-locked downloads, and an admin analytics dashboard.

---

## Features

- **Buyer**: Create/edit/delete projects & tasks, assign developers, pay for submissions, download ZIP solutions.
- **Developer**: View assigned tasks, start work, submit ZIP + hours logged.
- **Admin**: View platform stats (projects, tasks, revenue, users) with pie charts and cards.

---

## Key Functionality

- Secure JWT authentication with role-based authorization
- File upload (ZIP submissions) and download (to device Downloads folder)
- Hourly-rate based payments (auto-calculated on submission)
- Real-time data refresh with Riverpod state management
- Splash screen with auto-login and role-based routing
- Admin dashboard with visualizations (using fl_chart)

--- 

## Tech Stack

### Backend
- [FastAPI](https://fastapi.tiangolo.com/) (Python)
- SQLAlchemy (ORM)
- JWT (PyJWT) + bcrypt for auth
- [Alembic](https://alembic.sqlalchemy.org/en/latest/) (migrations)
<br></br>

### Frontend
- [Flutter](https://flutter.dev/) (Android)
- [Riverpod](https://riverpod.dev/) (state management)
- [Dio](https://pub.dev/packages/dio) (HTTP client)
<br></br>

### Database
- PostgreSQL

---

## Getting Started

### Prerequisites
- Python 3.10+
- Flutter SDK (latest stable)
- PostgreSQL (or you can use SQLite for quick testing)
<br></br>

### Backend Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/Nyctophilia58/taskforge.git
   cd taskforge/backend
   ```
   
2. Create virtual env & install dependencies:
   ```bash
   uv init backend
   source .venv/bin/activate
   uv add <package>
   ```
   
3. Set environment variables (copy `.env.example` to `.env`):
   ```text
   DATABASE_URL=postgresql://user:password@localhost/dbname
   SECRET_KEY=your_strong_secret
   ```
   
4. Run migrations:
   ```bash
   alembic upgrade head
   ```

5. Start server:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
<br>

### Frontend Setup

1. Navigate to client app:
   ```bash
   cd ../client
   ```
   
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update base URL in `lib/core/network/api_client.dart` to your backend (e.g., `http://10.0.2.2:8000` for Android emulator, `http:///<your-pc-ip>:8000` for real device).
   
5. Run:
   ```
   flutter run
   ```

---

## API Documentation

FastAPI provides interactive Swagger UI at `http://localhost:8000/docs`.

---

## Contribution
This project was developed as part of a technical assignment and is not currently open for external contributions. However, suggestions, improvements, and feedback are welcome. If you would like to propose changes:

1. Fork the repository
2. Create a new feature branch
3. Submit a pull request with a clear description of the changes

All contributions will be reviewed before merging.

---

## Contact

For questions, suggestions, or support:
- Open an issue on the [GitHub repository](https://github.com/Nyctophilia58/TaskForge)
- Or reach out at **nowtechdev@gmail.com**
