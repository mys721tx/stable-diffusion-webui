FROM python:3.10-slim as base

# Set build arguments
ARG WEBUI_VERSION=1.10.1
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cpu
ARG CPU_ONLY=true

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV WEBUI_VERSION=${WEBUI_VERSION}
ENV CPU_ONLY=${CPU_ONLY}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    python3 \
    python3-venv \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libice6 \
    libgoogle-perftools4 \
    libtcmalloc-minimal4 \
    bc \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build stage
FROM base as builder

WORKDIR /build

# Clone the repository
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git . \
    && git checkout v${WEBUI_VERSION}

# Create virtual environment and install dependencies
RUN python3 -m venv venv \
    && /build/venv/bin/pip install --upgrade pip setuptools wheel \
    && /build/venv/bin/pip install torch torchvision torchaudio --index-url ${TORCH_INDEX_URL} \
    && /build/venv/bin/pip install -r requirements_versions.txt

# Runtime stage
FROM base as runtime

# Create a non-root user
RUN useradd -m -s /bin/bash webui

# Set working directory
WORKDIR /app

# Copy application and virtual environment from builder
COPY --from=builder /build /app
COPY --from=builder /build/venv /app/venv

# Change ownership to webui user
RUN chown -R webui:webui /app

# Switch to webui user
USER webui

# Create startup script with conditional CPU/GPU flags
RUN if [ "$CPU_ONLY" = "true" ]; then \
      echo '#!/bin/bash\n\
source /app/venv/bin/activate\n\
python launch.py --listen --port 7860 --skip-torch-cuda-test --use-cpu all --precision full --no-half --no-download-sd-model "$@"' > /app/start.sh; \
    else \
      echo '#!/bin/bash\n\
source /app/venv/bin/activate\n\
python launch.py --listen --port 7860 --skip-torch-cuda-test --no-download-sd-model "$@"' > /app/start.sh; \
    fi \
    && chmod +x /app/start.sh

# Expose the default port
EXPOSE 7860

# Set the default command
CMD ["/app/start.sh"]
