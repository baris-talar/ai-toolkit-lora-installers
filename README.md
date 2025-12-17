ComfyUI GGUF RunPod Installer

This repository provides a focused installer script for setting up GGUF-based models and custom nodes inside an existing ComfyUI environment running on RunPod (JupyterLab).

The goal is to make ComfyUI environments stable, reproducible, and low-friction by automating common setup steps and avoiding frequent PyTorch, CUDA, and dependency conflicts.

This repository focuses on infrastructure and environment tooling, not model training or datasets.

⸻

What this repository provides

• A single installer script for RunPod-based ComfyUI environments
• Automated setup of GGUF-based model files
• Installation of common ComfyUI custom nodes
• Safe dependency handling to reduce breakage across nodes
• Practical defaults for GPU-based inference environments

⸻

Intended audience

This repository is intended for users who:

• Already have ComfyUI running
• Are using RunPod or similar JupyterLab-based GPU environments
• Want a clean way to install models and nodes without manual debugging

This is not a full ComfyUI installer and does not include Windows support.

⸻

Supported environment

• Linux (RunPod / JupyterLab)
• NVIDIA GPU (RTX-class recommended)
• Existing ComfyUI directory with models/ and custom_nodes/ present
• Python 3.x available on the system

⸻

Installation (RunPod / JupyterLab)
	1.	Navigate to your ComfyUI root directory
	2.	Upload the installer script:
comfyui-gguf-turbo-runpod-install.sh
	3.	Make the script executable
	4.	Run the script
	5.	Wait for installation to complete

The script will:
• Download GGUF-based model files
• Install and configure common custom nodes
• Set up a virtual environment for dependency isolation

⸻

Configuration

The script requires the following environment variable to be set before running:

• HF_BASE – Hugging Face base URL where model files are hosted

Example usage:
Set HF_BASE to your own Hugging Face repository containing the required model files.

Additional options such as CUDA version, Torch versions, and node selection can be overridden via environment variables inside the script.

⸻

Low-VRAM and stability notes

• GGUF models help reduce memory pressure
• Dependency pinning avoids common breakages
• Node installation is performed conservatively to prevent conflicts
• Virtual environments isolate ComfyUI from system Python

⸻

Troubleshooting

If you encounter CUDA or Torch-related errors:

• Verify your CUDA version
• Ensure Torch wheels match your CUDA version
• Avoid mixing system Python packages with the ComfyUI virtual environment

Most issues arise from mismatched CUDA and PyTorch versions.

⸻

Scope and intent

• This repository focuses on ML infrastructure tooling
• Scripts are provided as-is
• No models or datasets are included
• Users are responsible for respecting licenses of external assets

⸻

Credits

• ComfyUI and its open-source contributors
• PyTorch and NVIDIA CUDA ecosystems
