# AUTOMATIC1111 Stable Diffusion WebUI - Docker

This repository contains Docker configurations for building and running AUTOMATIC1111/stable-diffusion-webui in containers.

## Available Images

### Standard Image (CPU-Only)
- **Tag**: `latest`, `1.10.1`
- **File**: `Dockerfile`
- **Description**: Multi-stage optimized build with CPU-only PyTorch (universal compatibility)

### CUDA Optimized Image
- **Tag**: `latest-cuda`, `1.10.1-cuda`
- **File**: `Dockerfile.cuda`
- **Description**: CUDA 12.8 optimized build with cuDNN, xformers and performance enhancements

## Quick Start

### Using Docker Compose (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/mys721tx/stable-diffusion-webui.git
cd stable-diffusion-webui
```

2. Start the service:
```bash
docker-compose up -d
```

3. Access the WebUI at http://localhost:7860

### Using Docker Run

#### Standard CPU Version (Default)
```bash
docker run -d \
  --name stable-diffusion-webui \
  -p 7860:7860 \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/outputs:/app/outputs \
  ghcr.io/mys721tx/stable-diffusion-webui:latest
```

#### CUDA Optimized Version (Best Performance for NVIDIA GPUs)
```bash
docker run -d \
  --name stable-diffusion-webui-cuda \
  --gpus all \
  -p 7860:7860 \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/outputs:/app/outputs \
  ghcr.io/mys721tx/stable-diffusion-webui:latest-cuda
```

## GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds Docker images:

### Workflow (`build-docker.yml`)
- Builds on push to main/master and on tags
- Supports multi-platform builds (AMD64, ARM64)
- Builds two variants (standard CPU, CUDA optimized)
- Creates multi-arch manifests
- Supports manual triggers with version input
- Pushes to GitHub Container Registry

## Environment Variables

- `WEBUI_VERSION`: Version of stable-diffusion-webui to use (default: 1.10.1)
- `CPU_ONLY`: Set to "false" for GPU mode, "true" for CPU-only mode (default: true)

## Build Arguments

- `WEBUI_VERSION`: Version to build (default: 1.10.1)
- `TORCH_INDEX_URL`: PyTorch wheel index URL (default: CPU-only, use `https://download.pytorch.org/whl/cu128` for GPU)
- `CPU_ONLY`: Build in CPU-only mode with optimized startup flags (default: true)

## Volumes

- `/app/models`: Model files
- `/app/outputs`: Generated images
- `/app/extensions`: WebUI extensions
- `/app/embeddings`: Text embeddings
- `/app/config.json`: WebUI configuration
- `/app/ui-config.json`: UI configuration

## Building Locally

### Standard Image (CPU-Only, Default)
```bash
docker build -t stable-diffusion-webui .
```

### CUDA Optimized Image
```bash
docker build -f Dockerfile.cuda -t stable-diffusion-webui:cuda .
```

### Custom GPU Build (if needed)
```bash
docker build --build-arg CPU_ONLY=false --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128 -t stable-diffusion-webui:gpu .
```

## Requirements

### For GPU Support
- NVIDIA Docker runtime
- CUDA-compatible GPU
- Docker version 19.03+

### For CPU Only
- Docker version 19.03+
- Sufficient RAM (8GB+ recommended)

## Configuration

Create local directories for persistent data:
```bash
mkdir -p models outputs extensions embeddings
```

Copy configuration files if needed:
```bash
# Optional: customize configuration
cp config.json.example config.json
cp ui-config.json.example ui-config.json
```

## Troubleshooting

### Common Issues

1. **CUDA out of memory**: Reduce batch size or use CPU version
2. **Permission denied**: Check volume mount permissions
3. **Slow startup**: Initial run downloads models, subsequent runs are faster

### Logs
```bash
# View container logs
docker logs stable-diffusion-webui

# Follow logs in real-time
docker logs -f stable-diffusion-webui
```

## Security Notes

- The container runs as a non-root user (`webui`)
- No sensitive data is included in the image
- Models and outputs are stored in mounted volumes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker builds
5. Submit a pull request

## Author

* [Yishen Miao](https://github.com/mys721tx)

## License

[GNU General Public License, version 3](http://www.gnu.org/licenses/gpl-3.0.html)
