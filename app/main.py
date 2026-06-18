from fastapi import FastAPI, HTTPException, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest
import random
import time


app = FastAPI(
    title="CloudOps Status API",
    description=(
        "A FastAPI application for a DevOps, Kubernetes, CI/CD, "
        "and monitoring portfolio."
    ),
    version="1.1.0",
)


REQUEST_COUNT = Counter(
    "cloudops_request_total",
    "Total number of requests to the CloudOps Status API",
)

ERROR_COUNT = Counter(
    "cloudops_error_total",
    "Total number of simulated application errors",
)


@app.get("/")
def root():
    REQUEST_COUNT.inc()

    return {
        "service": "CloudOps Status API",
        "status": "running",
        "message": "Hello from the On-Premise Cloud-Native Platform",
    }


@app.get("/health")
def health_check():
    REQUEST_COUNT.inc()

    return {
        "status": "healthy",
        "timestamp": int(time.time()),
    }


@app.get("/simulate-error")
def simulate_error():
    REQUEST_COUNT.inc()
    ERROR_COUNT.inc()

    raise HTTPException(
        status_code=500,
        detail="Simulated internal server error for monitoring testing",
    )


@app.get("/simulate-load")
def simulate_load():
    REQUEST_COUNT.inc()

    total = 0

    for _ in range(100_000):
        total += random.randint(1, 100)

    return {
        "status": "load simulated",
        "result": total,
    }


@app.get("/metrics")
def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )
