# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ComfyUI is a powerful visual AI engine for stable diffusion workflows. It uses a graph/nodes/flowchart interface and is built with Python 3.12+, PyTorch, and aiohttp for the web server.

## Development Commands

### Running the Application
```bash
python main.py
```

### Testing
```bash
# Run all tests
pytest

# Run unit tests only
pytest tests-unit/

# Run inference tests only  
pytest tests/

# Run with specific markers
pytest -m "not inference"  # Skip inference tests
pytest -m "not execution"  # Skip execution tests
```

### Code Quality
```bash
# Lint with ruff (configured in pyproject.toml)
ruff check .

# Format with ruff
ruff format .
```

### Dependencies
```bash
# Install main dependencies
pip install -r requirements.txt

# Install test dependencies 
pip install -r tests-unit/requirements.txt
```

## Architecture Overview

### Core Components

- **Main Entry Point**: `main.py` - Sets up paths, logging, and starts the server
- **Server**: `server.py` - aiohttp web server handling HTTP/WebSocket connections
- **Node System**: `nodes.py` - Core node definitions and execution logic
- **Execution Engine**: `execution.py` - Workflow execution and graph processing
- **Model Management**: `comfy/model_management.py` - GPU memory and model loading
- **Path Management**: `folder_paths.py` - Configurable model and file paths

### Directory Structure

- `comfy/` - Core AI/ML functionality (models, samplers, utilities)
  - `ldm/` - Various diffusion model implementations (Flux, SD3, etc.)
  - `text_encoders/` - Text encoder implementations
  - `comfy_types/` - Type definitions and node interfaces
- `app/` - Application layer (user management, frontend, logging)
- `api_server/` - API routes and services
- `comfy_execution/` - Workflow execution engine
- `comfy_extras/` - Extended node implementations
- `comfy_api_nodes/` - External API integration nodes
- `custom_nodes/` - User-installable extensions
- `models/` - Model storage directories (checkpoints, VAEs, etc.)
- `tests/` and `tests-unit/` - Test suites

### Key Patterns

- **Node System**: All functionality exposed through nodes with INPUT_TYPES/RETURN_TYPES
- **Model Loading**: Models loaded on-demand with memory management
- **Execution Flow**: Graph-based execution with caching and interruption support
- **WebSocket Communication**: Real-time updates via WebSocket for UI
- **Plugin Architecture**: Custom nodes can extend functionality

### Configuration

- Models stored in `models/` subdirectories by type
- `extra_model_paths.yaml` for custom model paths
- Command-line arguments in `comfy/cli_args.py`
- Feature flags in `comfy_api/feature_flags.py`

### Common Development Tasks

When adding new nodes, follow the pattern in `nodes.py` with proper INPUT_TYPES, RETURN_TYPES, and CATEGORY definitions. The node system uses introspection to build the UI dynamically.

For model implementations, see existing patterns in `comfy/ldm/` and ensure proper memory management integration.

Testing should cover both unit tests (`tests-unit/`) and integration tests (`tests/`) with appropriate markers.