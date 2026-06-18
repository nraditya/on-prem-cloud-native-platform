from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_root_endpoint():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["service"] == "CloudOps Status API"
    assert response.json()["status"] == "running"


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert "timestamp" in response.json()


def test_metrics_endpoint():
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "cloudops_request_total" in response.text
    assert "cloudops_error_total" in response.text


def test_simulate_load_endpoint():
    response = client.get("/simulate-load")

    assert response.status_code == 200
    assert response.json()["status"] == "load simulated"


def test_simulate_error_returns_http_500():
    response = client.get("/simulate-error")

    assert response.status_code == 500
    assert response.json()["detail"] == (
        "Simulated internal server error for monitoring testing"
    )
