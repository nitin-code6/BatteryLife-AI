FROM python:3.11-slim

WORKDIR /app

# Install curl for container health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch CPU-only wheel (150MB instead of 4GB CUDA dependencies)
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Install remaining dependencies without reinstalling CUDA torch
COPY requirements.txt .
RUN grep -v -i "^torch" requirements.txt > reqs.txt && pip install --no-cache-dir -r reqs.txt

# Copy application source code
COPY app/ ./app/

# Create persistent storage directories
RUN mkdir -p artifacts processed

EXPOSE 8000

ENV PYTHONPATH=/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
