ComfyUI GGUF RunPod Installer

One-shot installer for setting up GGUF-based models and required custom nodes inside an existing ComfyUI environment on RunPod.

This script automates model downloads, node installation, and dependency pinning to avoid common CUDA, PyTorch, and package conflicts.

⸻

What this does
	•	Installs GGUF-based model files
	•	Clones and configures common ComfyUI custom nodes
	•	Pins dependencies for stability
	•	Uses a virtual environment to isolate Python packages

⸻

Who this is for
	•	Users who already have ComfyUI running
	•	RunPod / JupyterLab GPU environments
	•	Anyone who wants a reproducible, low-friction setup without manual debugging

This is not a full ComfyUI installer and does not include Windows support.

⸻

Requirements
	•	Linux (RunPod / JupyterLab)
	•	NVIDIA GPU
	•	Existing ComfyUI directory with models/ and custom_nodes/
	•	Python 3.x

⸻

Usage (RunPod)
	1.	Go to your ComfyUI root directory
	2.	Upload comfyui-gguf-turbo-runpod-install.sh
	3.	Make it executable and run it
	4.	Wait for completion

After running, start ComfyUI normally.

⸻

Configuration

The installer uses environment variables for customization.
	•	HF_BASE – Hugging Face base URL for model files
	•	Torch, CUDA, and node selection can be overridden inside the script

⸻

Scope
	•	Infrastructure and environment tooling only
	•	No models or datasets included
	•	Users are responsible for license compliance

⸻

Credits
	•	ComfyUI and its open-source contributors
	•	PyTorch and NVIDIA CUDA ecosystems
