import os
from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from src.schema_loader import initialize_database
from src.api.routers import inventory, shipments, analytics, audit, system

app = FastAPI(
    title="LogiChain DBMS Control Center & API Suite",
    description="Enterprise Supply Chain & Logistics Database Management System - Reference Implementation for CSE3001 DBMS Syllabus",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API Routers
app.include_router(inventory.router)
app.include_router(shipments.router)
app.include_router(analytics.router)
app.include_router(audit.router)
app.include_router(system.router)

WEB_DIR = Path(__file__).resolve().parent.parent / "web"
INDEX_HTML = WEB_DIR / "index.html"

@app.get("/", response_class=HTMLResponse)
@app.get("/dashboard", response_class=HTMLResponse)
def get_gui_dashboard():
    """Serves the interactive single-page Web GUI dashboard."""
    if INDEX_HTML.exists():
        return FileResponse(INDEX_HTML)
    return HTMLResponse("<h1>LogiChain DBMS API Online</h1><p>Visit <a href='/docs'>/docs</a> for Swagger UI.</p>")

@app.get("/api/health")
def api_health():
    return {
        "system": "LogiChain Supply Chain DBMS",
        "status": "ONLINE",
        "gui_url": "/",
        "docs_url": "/docs",
        "syllabus_coverage": "CSE3001 Units 1-5 & Labs 1-11"
    }
