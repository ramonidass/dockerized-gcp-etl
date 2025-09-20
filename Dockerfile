FROM python:3.11-slim as base

WORKDIR /app

RUN pip install uv

COPY pyproject.toml .
RUN uv pip install --system .

# ---

FROM python:3.11-slim as final

WORKDIR /app

# Copy the installed dependencies from the base image
COPY --from=base /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

COPY app app
COPY main.py .
COPY settings.py .

CMD ["sh", "-c", "gunicorn -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:${PORT:-8080} main:app"]
