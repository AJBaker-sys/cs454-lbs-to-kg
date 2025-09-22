# Design Rationale for Pounds to Kilograms REST Service

## Overview
This project adapts the CS454 Project 1 spec to a Dockerized setup using Python/Flask for the API, Gunicorn for WSGI serving, Nginx for reverse proxy. The goal is reproducibility, security, and simplicity while meeting API requirements. 

## Key Design Choices
- **Stack Selection**:
  - Python/Flask: Simple, lightweight for REST API. Aligns with user preference over Node.js. Handles query params, errors, and JSON responses natively.
  - Gunicorn: Production-ready WSGI server for Flask (better than dev server). Runs on internal port 8080.
  - Nginx: Reverse proxy for handling HTTP/HTTPS, load balancing (future-proof), and Certbot integration. Forces HTTPS by redirecting 80→443 after cert setup.
  - Supervisor: Manages multiple processes (Gunicorn + Nginx) in one container. Logs to stdout for Docker compatibility.
  - Docker: Encapsulates everything for reproducible deploys. Base Ubuntu 22.04 for system pkgs (Nginx/Certbot). No separate containers per user request.

- **API Implementation**:
  - Endpoint: GET /convert?lbs=<number>. Uses float() for parsing, math.isfinite for NaN/Inf checks.
  - Rounding: round(..., 3) for kg to 3 decimals.
  - Errors: 400 for missing/invalid, 422 for negative/non-finite. JSON error messages as spec.
  - No auth/DB: Minimal per spec.

- **Security Considerations**:
  - Least privilege: EC2 SG limits SSH to user IP; 80/443 open for public API.
  - HTTPS force: Certbot sets up redirect. Self-signed fallback if needed (edit nginx.conf).
  - Non-root: Supervisor/Gunicorn could use custom user (add in Dockerfile: useradd appuser), but root for simplicity.
  - No root run for app: Gunicorn under ec2-user if on host, but in Docker it's isolated.
  - Logs: Stdout/stderr for visibility (docker logs). No logrotate (cap via Docker limits).

- **Reliability & DevOps**:
  - Survives reboot: Docker run -d with autorestart in Supervisor.
  - Reproducible: Dockerfile builds everything. Volumes persist certs.
  - Testing: Unit tests in tests/ for edge cases. README curl examples.
  - Cost: t2.micro free-tier. Cleanup in README.
  - Structure: Clean, with .gitignore/.dockerignore. Black for formatting.

- **Alternatives Considered**:
  - Multi-container (Docker Compose): Better for separation (Flask + Nginx services), but for our purposes this microservice makes sense to do in one container.
  - Self-signed certs: Simpler (no domain), but Let's Encrypt for real HTTPS. If issues, generate via openssl in entrypoint.
  - No Supervisor: Use bash script to run processes in bg, but Supervisor is more robust.
  - Other stacks: Node/Express per original, but I prefer Python/Flask.

- **Potential Improvements**:
  - Add health checks (Docker HEALTHCHECK).
  - Env vars for port/config.
  - Monitoring (Prometheus if scaled).
  - Rotate logs if volume grows.