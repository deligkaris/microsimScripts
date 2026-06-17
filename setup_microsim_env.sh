#!/bin/bash
# Author: Christos Deligkaris
# Purpose: One-time setup of the SHARED microsim conda environment in PAS2139
#          project space. Run this ONCE on a login node. After it succeeds,
#          every PAS2139 member can use the environment via submic with no
#          further setup (project space is already group-readable).
#
# Usage:   bash setup_microsim_env.sh
#
# Dependencies come from microsim's pyproject.toml (runtime only; the dev
# deps flake8/ipython/black and the interactive-only ipykernel are omitted).

set -e   # stop on first error

# ---- locations (override via environment if desired) ----
condaEnv="${MICROSIM_ENV:-/fs/ess/PAS2139/envs/microsim}"
# Confirm the exact module name first with:  module spider miniconda3
condaModule="${MICROSIM_CONDA_MODULE:-miniconda3/24.1.2-py310}"

echo "Loading conda module: $condaModule"
module load "$condaModule"

# ---- first-time channel configuration ----
# Use conda-forge and avoid the proprietary 'defaults' channel.
# These settings are per-user and persist in ~/.condarc; harmless to re-run.
echo "Configuring conda channels (conda-forge, strict priority)..."
conda config --remove channels defaults 2>/dev/null || true
conda config --add channels conda-forge
conda config --set channel_priority strict

# ---- create the shared environment in project space ----
# python 3.12 (microsim requires >=3.12); all RUNTIME deps installed at once.
# Version bounds translate microsim's poetry carets:
#   ^2.2.6 -> >=2.2.6,<3      ^0.14.0 -> >=0.14,<0.15      ^0.30 -> >=0.30,<0.31
echo "Creating shared environment at: $condaEnv"
conda create --yes --prefix "$condaEnv" \
    python=3.12 \
    "numpy>=2.2.6,<3" \
    "pandas>=2.2,<3" \
    "statsmodels>=0.14,<0.15" \
    "scipy>=1.16,<2" \
    "matplotlib>=3.10.7,<4" \
    "lifelines>=0.30,<0.31"

# ---- verify ----
echo "Activating and verifying..."
export PYTHONNOUSERSITE=True
source activate "$condaEnv"
which python
python --version
python -c "import numpy, pandas, statsmodels, scipy, matplotlib, lifelines; \
print('imports OK; numpy', numpy.__version__, '| pandas', pandas.__version__)"

echo ""
echo "Done. Shared environment is ready at: $condaEnv"
echo "Group members can now run jobs with submic (no per-user setup needed)."
echo ""
echo "NOTE: keep WRITE access to $condaEnv for yourself only (to update"
echo "      packages); group members need just read+execute, which project"
echo "      space already provides."
