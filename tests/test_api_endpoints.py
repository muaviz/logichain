import pytest
from fastapi.testclient import TestClient
from src.api.app import app

@pytest.fixture
def client():
    return TestClient(app)

def test_gui_dashboard_endpoint(client):
    res = client.get("/")
    assert res.status_code == 200
    assert "LogiChain DBMS" in res.text

def test_system_tables_api(client):
    res = client.get("/system/tables")
    assert res.status_code == 200
    tables = res.json()
    assert len(tables) >= 20
    assert any(t["table_name"] == "EMPLOYEE" for t in tables)

def test_custom_sql_query_api(client):
    res = client.post("/system/query", json={"query": "SELECT product_name FROM PRODUCT WHERE product_id = 301;"})
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "SUCCESS"
    assert data["rows"][0]["product_name"] == "Solid Oak Heavy Duty Desktop"

def test_custom_query_error_handling(client):
    res = client.post("/system/query", json={"query": "SELECT * FROM NON_EXISTENT_TABLE;"})
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "ERROR"
    assert "no such table" in data["error_message"].lower()

def test_lab_query_api(client):
    res = client.get("/system/labs/lab01")
    assert res.status_code == 200
    data = res.json()
    assert "Boeing Certified Pilots" in [s["title"] for s in data["sections"]]
