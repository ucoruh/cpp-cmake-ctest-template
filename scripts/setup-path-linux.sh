#!/bin/bash
# setup-path-linux.sh - SOURCE it. Puts per-user tool folders on PATH:
#   ~/.dotnet (only if a per-user .NET SDK is installed there by 4-install-tools-linux.sh) and ~/.dotnet/tools
#       (dotnet-reportgenerator-globaltool)
#   ~/.local/bin   (pip --user: coverxygen, junit2html, mkdocs, gcovr)
# A non-login shell does not have these on PATH, and an older distro dotnet (e.g. .NET 3.1 on Ubuntu 20.04) is too
# old to run current ReportGenerator, so the per-user one goes first. DOTNET_ROOT is set ONLY when ~/.dotnet really
# holds a .NET: on GitHub's runners .NET is installed elsewhere (setup-dotnet) and a wrong DOTNET_ROOT would break it.
if [ -x "$HOME/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$HOME/.dotnet:$PATH"
fi
export PATH="$HOME/.dotnet/tools:$HOME/.local/bin:$PATH"
