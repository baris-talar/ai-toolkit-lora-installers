AI-Toolkit LoRA Installers (Local & RunPod)

This repository contains installer scripts and setup notes for training LoRA models using AI-Toolkit on both local GPUs and cloud GPUs via RunPod.

The goal is to make LoRA training reproducible, low-friction, and stable by automating environment setup and avoiding common CUDA / PyTorch configuration issues, especially under low-VRAM constraints.

⸻

What this repository provides

• Automated installation of AI-Toolkit
• CUDA-enabled PyTorch environment setup
• Local (Windows) and RunPod deployment paths
• LoRA training workflows for Z-Image Turbo
• Practical configuration for less than 12GB VRAM
• Common failure cases and fixes

This repository focuses on infrastructure and tooling, not model files.

⸻

Supported environments

Local (Windows)

• NVIDIA GPUs (RTX / GTX)
• CUDA 12.6 for RTX 40/30/20/GTX
• CUDA 12.8 for RTX 50
• Python 3.10 (64-bit)
• Node.js 18 or 20 (LTS)
• Git

Cloud

• RunPod GPU instances (RTX 4090 or better recommended)
• PyTorch 2.8 templates

⸻

Local installation (Windows)

Requirements

• CUDA installed and available in PATH
• Python 3.10 (64-bit)
• Git
• Node.js 18 or 20 (LTS)

Steps
	1.	Download the file AI-TOOLKIT_AUTO_INSTALL.bat
	2.	Place it in a directory without spaces in the path
	3.	Run the script
	4.	Select the option matching your GPU and CUDA version
	5.	Wait for installation to complete
	6.	Launch the AI-Toolkit UI using the provided launcher

⸻

RunPod installation

Pod setup
	1.	Create a RunPod account
	2.	Deploy a new Pod
	3.	Select a GPU (RTX 4090 or better recommended)
	4.	Choose a PyTorch 2.8 template
	5.	Set container disk size to 100GB
	6.	Expose ports 8888 and 8675
	7.	Add environment variable AI_TOOLKIT_AUTH with your chosen password

Installation
	1.	Upload the installer script AI-TOOLKIT_AUTO_INSTALL-RUNPOD.sh
	2.	Make the script executable
	3.	Run the installer script
	4.	Wait for installation to complete

After installation, access the AI-Toolkit UI via port 8675.

⸻

Low-VRAM training notes

• LoRA training is possible with less than 12GB VRAM using layer offloading
• Resolution selection has a significant impact on memory usage
• Z-Image Turbo works best with balanced timestep bias for characters
• High-noise bias is recommended for style training
• Training speed and stability depend heavily on VRAM availability

⸻

Troubleshooting

Torch not compiled with CUDA enabled

If you encounter an error indicating Torch is not compiled with CUDA enabled:

• Uninstall the existing PyTorch packages
• Reinstall PyTorch using the CUDA-specific wheels matching your CUDA version
• For CUDA 12.6 use cu126
• For CUDA 12.8 use cu128
• Verify the CUDA version using the nvcc version command

⸻

Lessons learned

• CUDA and PyTorch version mismatch is the most common failure
• Environment reproducibility matters more than model choice
• Automating setup saves more time than manual debugging
• Low-VRAM optimisation requires infrastructure-level thinking

⸻

Scope and intent

• This repository focuses on ML infrastructure and tooling
• Scripts are provided as-is for reproducible setup
• Model files and datasets are not included
• Users are responsible for respecting model and dataset licenses

⸻

Credits

• AI-Toolkit and upstream open-source contributors
• NVIDIA CUDA and PyTorch ecosystems
