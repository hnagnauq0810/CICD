"""Tests for the demo FastAPI application."""

from fastapi.testclient import TestClient

from cicd_pipeline_demo.main import add, app


client = TestClient(app)


def test_read_root() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"message": "CI/CD pipeline demo is running"}


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_add_function() -> None:
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_add_endpoint() -> None:
    response = client.get("/add/10/7")

    assert response.status_code == 200
    assert response.json() == {"result": 17}
