import math
import pytest
from src.app import app  # assuming your Flask app is src/app.py

@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client

def test_normal(client):
    res = client.get("/convert?lbs=150")
    data = res.get_json()
    assert res.status_code == 200
    assert math.isclose(data["kg"], 68.039, rel_tol=1e-3)

def test_zero(client):
    res = client.get("/convert?lbs=0")
    data = res.get_json()
    assert res.status_code == 200
    assert data["kg"] == 0.0

def test_edge(client):
    res = client.get("/convert?lbs=0.1")
    data = res.get_json()
    assert res.status_code == 200
    assert math.isclose(data["kg"], 0.045, rel_tol=1e-3)

def test_missing(client):
    res = client.get("/convert")
    assert res.status_code == 400

def test_negative(client):
    res = client.get("/convert?lbs=-5")
    assert res.status_code == 422

def test_nan(client):
    res = client.get("/convert?lbs=NaN")
    assert res.status_code == 400
