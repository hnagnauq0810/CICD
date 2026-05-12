"""FastAPI application used by the CI/CD pipeline demo."""

from fastapi import FastAPI


app = FastAPI(
    title="CI/CD Pipeline Demo",
    description="A small Python API for demonstrating CI/CD with GitHub Actions.",
    version="0.1.0",
)


def add(left: int, right: int) -> int:
    """Return the sum of two integers."""
    return left + right


@app.get("/")
def read_root() -> dict[str, str]:
    """Return a welcome message."""
    return {"message": "CI/CD pipeline demo is running"}


@app.get("/health")
def health_check() -> dict[str, str]:
    """Return application health status for deployment verification."""
    return {"status": "ok"}


@app.get("/add/{left}/{right}")
def add_numbers(left: int, right: int) -> dict[str, int]:
    """Return the result of adding two numbers."""
    return {"result": add(left, right)}
