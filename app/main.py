from fastapi import FastAPI, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = FastAPI(
    title="CloudOps Status API",
    description="A simple FastAPI application for DevOps, Kubernetes, CI/CD, and monitoring portfolio.",
    version="1.0.0"
)

REQUEST_COUNT = Counter(
    "cloudops_request_total",
    "Total number of requests to the CloudOps Status API"
)

ERROR_COUNT = Counter(
    "cloudops_error_total",
    "Total number of simulated errors"
)


@app.get("/")
def root():
    REQUEST_COUNT.inc()
    return {
        "service": "CloudOps Status API",
        "status": "running",
        "message": "Hello from the On-Premise Cloud-Native Platform"
    }


@app.get("/health")
def health_check():
    REQUEST_COUNT.inc()
    return {
        "status": "healthy",
        "timestamp": int(time.time())
    }


@app.get("/simulate-error")
def simulate_error():
    REQUEST_COUNT.inc()
    ERROR_COUNT.inc()
    return {
        "status": "error",
        "message": "This is a simulated error for monitoring testing"
    }


@app.get("/simulate-load")
def simulate_load():
    REQUEST_COUNT.inc()
    total = 0
    for i in range(100000):
        total += random.randint(1, 100)
    return {
        "status": "load simulated",
        "result": total
    }


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
