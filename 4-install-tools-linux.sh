#!/bin/bash
# 4-install-tools-linux.sh - installs every tool the template uses (Ubuntu/Debian; native Linux and WSL).
# Safe to re-run. Needs sudo for apt. See docs/guide/install.en.md for the verification commands.
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1

echo "=== apt packages: compiler, CMake, Ninja, Doxygen, Graphviz, lcov (genhtml), AStyle, curl, zip, Python"
sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build doxygen graphviz lcov astyle curl zip unzip \
    python3 python3-pip python3-venv || { echo "ERROR: apt-get install failed." >&2; exit 1; }

echo "=== A per-user, current .NET SDK (official dotnet-install.sh)"
# Many distros only package an old .NET (Ubuntu 20.04's apt dotnet-sdk is .NET 3.1), too old to run
# the current ReportGenerator (needs a current .NET runtime). Install a current LTS SDK into ~/.dotnet:
# per-user, non-destructive (does not touch a distro-packaged dotnet), found first on PATH.
if [ ! -x "$HOME/.dotnet/dotnet" ]; then
    curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh || { echo "ERROR: could not download dotnet-install.sh" >&2; exit 1; }
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh --channel LTS || { echo "ERROR: dotnet-install failed." >&2; exit 1; }
fi
# shellcheck disable=SC1091
source scripts/setup-path-linux.sh
if ! grep -q '\.dotnet/tools' "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ''
        echo '# Added by 4-install-tools-linux.sh (per-user .NET SDK, ReportGenerator, pip --user tools)'
        echo 'export DOTNET_ROOT="$HOME/.dotnet"'
        echo 'export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/.local/bin:$PATH"'
    } >> "$HOME/.bashrc"
    echo "Added the per-user tool folders to PATH in ~/.bashrc (open a new shell, or: source ~/.bashrc)"
fi

echo "=== ReportGenerator"
dotnet tool update --global dotnet-reportgenerator-globaltool || dotnet tool install --global dotnet-reportgenerator-globaltool || { echo "ERROR: could not install ReportGenerator." >&2; exit 1; }

echo "=== Python packages: mkdocs-material, coverxygen, junit2html, gcovr (requirements.txt)"
python3 -m pip install --user --upgrade -r requirements.txt 2>/dev/null \
  || python3 -m pip install --user --upgrade --break-system-packages -r requirements.txt \
  || { echo "ERROR: pip failed - see the messages above." >&2; exit 1; }

echo "=== GitHub CLI (gh) for 10-release-linux.sh"
if ! command -v gh >/dev/null 2>&1; then
    sudo apt-get install -y gh 2>/dev/null || echo "NOTE: 'gh' is not in your apt sources - install it from https://cli.github.com/ (needed only for a real release)."
fi

echo "=== PlantUML (optional; used only if a diagram needs it)"
if [ ! -f plantuml.jar ]; then
    curl -sSL -f -o plantuml.jar https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar \
        && echo "plantuml.jar downloaded." || { echo "NOTE: plantuml.jar could not be downloaded - it is optional, continuing."; rm -f plantuml.jar; }
else
    echo "plantuml.jar already present."
fi

echo
echo "Done. Verify with the commands in docs/guide/install.en.md (cmake --version, doxygen --version, ...)."
