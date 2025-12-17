#!/usr/bin/env bash
# RunPod ComfyUI GGUF-TURBO installer (refactor-only)

set -euo pipefail

# ───────────────────── Settings (override via env) ─────────────────────

# Hugging Face base URL (must be provided by user)
HF_BASE="${HF_BASE:-}"
if [[ -z "${HF_BASE}" ]]; then
  echo "[ERROR] HF_BASE is empty. Set HF_BASE to your Hugging Face model base URL."
  exit 1
fi

MODEL_VERSION="${MODEL_VERSION:-Q8_0}"

# Python / venv
PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-venv}"

# Torch / CUDA (RunPod cu121 is typical)
TORCH_VERSION="${TORCH_VERSION:-2.4.0}"
TORCHVISION_VERSION="${TORCHVISION_VERSION:-0.19.0}"
TORCHAUDIO_VERSION="${TORCHAUDIO_VERSION:-2.4.0}"
CUDA_TAG="${CUDA_TAG:-cu121}"
TORCH_INDEX_URL="https://download.pytorch.org/whl/${CUDA_TAG}"

# Node selection
INSTALL_ALL_NODES="${INSTALL_ALL_NODES:-false}"
REQUIRED_NODES="${REQUIRED_NODES:-"ComfyUI-GGUF ComfyUI-WanVideoWrapper ComfyUI-VideoHelperSuite ComfyUI-KJNodes ComfyUI-Impact-Pack ComfyUI_essentials ComfyUI-Manager"}"

# Fragile node toggles
ALLOW_SAM2="${ALLOW_SAM2:-false}"
MANAGER_ENABLE_MATRIX="${MANAGER_ENABLE_MATRIX:-false}"

# Common pins
PIN_PILLOW_MIN="${PIN_PILLOW_MIN:-11.0.0}"
PIN_OPENCV_HEADLESS="${PIN_OPENCV_HEADLESS:-4.12.0.88}"
PIN_URLLIB3_1X="${PIN_URLLIB3_1X:-1.26.18}"
PIN_LIBROSA_VERSION="${PIN_LIBROSA_VERSION:-}"

export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_ROOT_USER_ACTION=ignore

# ───────────────────── Small helpers ─────────────────────
SUDO="sudo"
if [[ "$(id -u)" -eq 0 ]]; then SUDO=""; fi

fail() { echo "[ERROR] $*"; exit 1; }

ensure_pkg() {
  local bin="$1"
  command -v "$bin" &>/dev/null && return 0
  echo "[INFO] installing $bin ..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y "$bin"
}

download_if_missing() {
  local out="$1" url="$2"
  if [[ -f "$out" ]]; then
    echo " • $(basename "$out") exists – skip"
    return 0
  fi
  echo " • downloading $(basename "$out")"
  mkdir -p "$(dirname "$out")"
  curl -L --fail --progress-bar --show-error -o "$out" "$url"
}

clone_node() {
  local folder="$1" repo="$2" extra_flag="${3:-}"
  if [[ -d "custom_nodes/$folder" ]]; then
    echo " [SKIP] $folder already present."
  else
    git clone $extra_flag "$repo" "custom_nodes/$folder"
  fi
}

# ───────────────────── System deps ─────────────────────
ensure_pkg curl
ensure_pkg git
ensure_pkg git-lfs
git lfs install

# ───────────────────── Sanity checks ─────────────────────
[[ -d "models" && -d "custom_nodes" ]] || fail "Run this inside ComfyUI root (needs models/ and custom_nodes/)."
COMFY_ROOT="$(pwd)"

# ───────────────────── Python venv ─────────────────────
if [[ ! -d "$VENV_DIR" ]]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

PYTHON="$(command -v python)"
PIP="$(command -v pip)"

"$PYTHON" -m pip install --upgrade pip setuptools wheel

# ───────────────────── Models ─────────────────────
echo
echo "──────── Downloading GGUF-TURBO Model Files ────────"

download_if_missing "models/text_encoders/Qwen3-4B-UD-Q6_K_XL.gguf" \
  "${HF_BASE}/Qwen3-4B-UD-Q6_K_XL.gguf?download=true"

download_if_missing "models/vae/ae.safetensors" \
  "${HF_BASE}/ae.safetensors?download=true"

download_if_missing "models/unet/gguf_turbo-${MODEL_VERSION}.gguf" \
  "${HF_BASE}/z_image_turbo-${MODEL_VERSION}.gguf?download=true"

# ───────────────────── Nodes ─────────────────────
echo
echo "──────── Cloning Custom Nodes ────────"

clone_node "ComfyUI-Manager"           "https://github.com/ltdrdata/ComfyUI-Manager.git"
clone_node "ComfyUI-GGUF"              "https://github.com/city96/ComfyUI-GGUF.git"
clone_node "rgthree-comfy"             "https://github.com/rgthree/rgthree-comfy.git"
clone_node "ComfyUI-Easy-Use"          "https://github.com/yolain/ComfyUI-Easy-Use"
clone_node "ComfyUI-KJNodes"           "https://github.com/kijai/ComfyUI-KJNodes.git"
clone_node "ComfyUI_UltimateSDUpscale" "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
clone_node "ComfyUI_essentials"        "https://github.com/cubiq/ComfyUI_essentials.git"
clone_node "wlsh_nodes"                "https://github.com/wallish77/wlsh_nodes.git"
clone_node "RES4LYF"                   "https://github.com/ClownsharkBatwing/RES4LYF"
clone_node "ComfyUI_tinyterraNodes"    "https://github.com/TinyTerra/ComfyUI_tinyterraNodes"

# ───────────────────── Torch + base pins ─────────────────────
echo
echo "──────── Installing baseline (Torch, Pillow, OpenCV) ────────"

"$PYTHON" -m pip install \
  --index-url "$TORCH_INDEX_URL" --extra-index-url https://pypi.org/simple \
  "torch==${TORCH_VERSION}+${CUDA_TAG}" \
  "torchvision==${TORCHVISION_VERSION}+${CUDA_TAG}" \
  "torchaudio==${TORCHAUDIO_VERSION}+${CUDA_TAG}"

"$PYTHON" -m pip uninstall -y opencv-python || true
"$PYTHON" -m pip install "opencv-python-headless==${PIN_OPENCV_HEADLESS}"
"$PYTHON" -m pip install "pillow>=${PIN_PILLOW_MIN}"

if [[ "$MANAGER_ENABLE_MATRIX" == "true" ]]; then
  "$PYTHON" -m pip install "urllib3==${PIN_URLLIB3_1X}"
fi

# ───────────────────── Patch fragile nodes ─────────────────────
if [[ "$ALLOW_SAM2" != "true" && -f "custom_nodes/ComfyUI-Impact-Pack/requirements.txt" ]]; then
  sed -i 's@^git+https://github.com/facebookresearch/sam2.*@# sam2 disabled for stability@' \
    "custom_nodes/ComfyUI-Impact-Pack/requirements.txt" || true
fi

if [[ "$MANAGER_ENABLE_MATRIX" != "true" && -f "custom_nodes/ComfyUI-Manager/requirements.txt" ]]; then
  sed -i 's/^matrix-client==0\.4\.0/# matrix disabled by installer/' \
    "custom_nodes/ComfyUI-Manager/requirements.txt" || true
fi

# ───────────────────── Constraints snapshot ─────────────────────
"$PYTHON" -m pip freeze | sed '/^-e /d' > /tmp/constraints.txt

# ───────────────────── Install node requirements ─────────────────────
echo
echo "──────── Installing node requirements ────────"

REQ_FILES=()
if [[ "$INSTALL_ALL_NODES" == "true" ]]; then
  mapfile -t REQ_FILES < <(find custom_nodes -name requirements.txt)
else
  for node_dir in $REQUIRED_NODES; do
    [[ -f "custom_nodes/$node_dir/requirements.txt" ]] && REQ_FILES+=("custom_nodes/$node_dir/requirements.txt")
  done
fi

for req_path in "${REQ_FILES[@]}"; do
  echo " • $req_path"
  pushd "$(dirname "$req_path")" >/dev/null
  pip install --prefer-binary --no-build-isolation -r requirements.txt || \
  pip install --prefer-binary -r requirements.txt || true
  popd >/dev/null
done

# ───────────────────── Extras ─────────────────────
pip install gguf piexif || true
if [[ -n "$PIN_LIBROSA_VERSION" ]]; then
  pip install "librosa==$PIN_LIBROSA_VERSION" || true
else
  pip install librosa || true
fi

echo
echo "✅ GGUF-TURBO models and nodes are ready"