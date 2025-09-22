# Design Rationale for Pounds to Kilograms REST Service
This document outlines the reasoning behind my design choices for the project. Initially, I wasn’t sure which direction to take, so I started with a kind of brainstorming section to explore and refine my approach before settling on the final structure and implementation

## Brainstorming
This project adapts the CS454 Project 1 specification into a Dockerized setup, utilizing Python/Flask for the API, Gunicorn for WSGI serving, and Nginx for reverse proxy, with the potential to enforce HTTPS using Let's Encrypt for certificates. The aim is to ensure reproducibility, security, and simplicity while fulfilling API requirements. I'm deciding between using a single container with Supervisor for process management (not ideal, but workable) or opting for a Docker Compose setup, which seems easier. HTTPS could also be enforced through an Nginx redirect after running Certbot.

## My Design Choices
- **Stack Selection**:
  - Python/Flask: Simple, lightweight for REST API. Handles query params, errors, and JSON responses natively.
  - Gunicorn: WSGI server for Flask (better than dev server). Runs on internal port 8080.
  - Nginx: Acts as a reverse proxy for handling HTTP/HTTPS traffic, load balancing (future scalability), and integrating with Certbot. I could also use it to enforce HTTPS by redirecting traffic from port 80 to 443 after certificate setup.
  - (Potentially) Supervisor: Manages multiple processes (Gunicorn + Nginx) in one container. Logs to stdout for Docker compatibility.
  - Docker: Encapsulates everything for reproducible deploys. Base Ubuntu 22.04 for system pkgs (Nginx/Certbot).
  - (Potentially) Let's Encrypt/Certbot: Provides free TLS certificates via the HTTP challenge on port 80. Configuration is managed with environment variables (DOMAIN, EMAIL). Certbot auto-updates the Nginx configuration for the redirect. If the domain isn't available, it falls back to a self-signed certificate, with manual Nginx edits required.

- **API Implementation**:
  - Endpoint: GET /convert?lbs=\<number>. Uses float() for parsing, math.isfinite for NaN/Inf checks.
  - Rounding: round(..., 3) for kg to 3 decimals.
  - Errors: 400 for missing/invalid, 422 for negative/non-finite. JSON error messages as spec.
  - No auth/DB: Minimal per spec.

- **Security Considerations**:
  - Least privilege: EC2 SG limits SSH to user IP; 80 open for public API.
  - No root run for app: Gunicorn under ec2-user if on host, but in Docker it's isolated and runs with a non-root user for added security.
  - Logs: Stdout/stderr for visibility (docker-compose logs). There isn't a log rotation built-in, but Docker does have some capability to prevent excessive logs.

- **Reliability & DevOps**:
  - Survives reboot: The setup is designed to automatically restart on reboot using         Docker Compose’s restart: always policy, ensuring      the service stays up after a system restart. Also make sure the command: systemctl enable docker is run just to be sure docker starts on boot by default.
  - Reproducible: Dockerfile builds everything. Volumes persist certs.
  - Testing: Made a script for testing. README also has curl examples.
  - Cost: t3.micro free-tier. Cleanup in README.
  - Structure: Clean, with .gitignore/.dockerignore.

- **Alternatives Considered**:
  - Single-container: Initially considered a single container setup, which might’ve been simpler for a basic microservice like this, but Docker Compose ultimately provides better flexibility and scalability.
  - Self-signed certificates: A simpler option if no domain is available, but for this project, I’ve opted to skip certificates altogether and just serve via HTTP on port 80 to keep it simple. If I were to implement HTTPS in the future, I could use Let's Encrypt, or fallback to generating certificates via openssl in the entrypoint.
  - Process Management (Supervisor or Bash): Instead of using Supervisor or a bash script to manage processes, I opted for Docker Compose to handle the orchestration of Gunicorn and Nginx in separate containers. Docker Compose makes the setup more modular and easier to maintain.
  - Other Stacks: While Node/Express was considered per the original guidelines, I prefer Python/Flask due to my familiarity with it.

- **Potential Improvements**:
  - Health Checks: Plan to add Docker HEALTHCHECK instructions to monitor container status and ensure reliable operation.
  - Monitoring: For potential scaling in the future, adding monitoring tools like Prometheus could help track system performance and API health.
  - Log Rotation: Implement log rotation or set Docker limits if log volume grows over time, to prevent potential storage issues.
