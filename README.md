# FastAPI Shop

A modern e-commerce shop application built with FastAPI backend and a frontend (to be implemented).

## Project Structure

```
fastapi-shop/
├── backend/          # FastAPI backend application
│   └── venv/        # Python virtual environment
├── frontend/        # Frontend application (to be implemented)
└── main.py          # Temporary file (can be removed)
```

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Git (for version control)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd fastapi-shop
```

### 2. Set Up Backend

Navigate to the backend directory:

```bash
cd backend
```

### 3. Create Virtual Environment

If you haven't already created a virtual environment:

```bash
python -m venv venv
```

### 4. Activate Virtual Environment

**On Windows (Git Bash / MINGW64):**
```bash
source venv/Scripts/activate
```

**On Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```

**On Windows (Command Prompt):**
```cmd
venv\Scripts\activate.bat
```

**On Linux/macOS:**
```bash
source venv/bin/activate
```

After activation, you should see `(venv)` at the beginning of your command prompt.

### 5. Install Dependencies

Once the virtual environment is activated, install the required packages:

```bash
pip install -r requirements.txt
```

> **Note:** If `requirements.txt` doesn't exist yet, create it with your project dependencies (e.g., `fastapi`, `uvicorn`, etc.)

### 6. Run the Application

Start the FastAPI development server:

```bash
uvicorn main:app --reload
```

Or if your main application file is located elsewhere:

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### 7. Access API Documentation

FastAPI provides automatic interactive API documentation:

- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`

## Development

### Deactivate Virtual Environment

When you're done working, deactivate the virtual environment:

```bash
deactivate
```

### Adding New Dependencies

1. Activate your virtual environment
2. Install the package: `pip install <package-name>`
3. Update requirements.txt: `pip freeze > requirements.txt`

## Environment Variables

Create a `.env` file in the `backend` directory for environment-specific configurations:

```env
DATABASE_URL=postgresql://user:password@localhost/dbname
SECRET_KEY=your-secret-key-here
DEBUG=True
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test your changes
4. Submit a pull request

## License

[Add your license here]

## Notes

- The virtual environment (`venv`) should be added to `.gitignore` and not committed to version control
- Always activate the virtual environment before working on the project
- Keep `requirements.txt` up to date with all project dependencies

