#!/bin/bash
# setup-path-linux.sh - SOURCE it. Puts per-user tool folders on PATH:
#   ~/.dotnet and ~/.dotnet/tools  (dotnet-reportgenerator-globaltool, a current .NET SDK
#                                   installed by 4-install-tools-linux.sh)
#   ~/.local/bin                   (pip --user: coverxygen, junit2html, mkdocs, gcovr)
# A non-login shell does not have these on PATH, and an older distro dotnet (e.g. .NET 3.1 on
# Ubuntu 20.04) is too old to run current ReportGenerator, so the per-user one goes first.
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/.local/bin:$PATH"
