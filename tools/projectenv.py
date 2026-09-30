#!/usr/bin/env python3
"""Read project.env (PROJECT_NAME, VERSION, GITHUB_REPO) - the single place a project is named.

Every script, workflow and tool of this template gets the project identity from here, so a student
renames the project by editing one file. Also usable from the shell:

    python3 tools/projectenv.py PROJECT_NAME      # prints the value
    python3 tools/projectenv.py --github-env      # KEY=value lines for $GITHUB_ENV (comments removed)
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load(root: Path = ROOT) -> dict[str, str]:
    """Return project.env as a dict, plus the derived REPO_URL, SITE_URL, ARCH-independent values."""
    env: dict[str, str] = {}
    for raw in (root / "project.env").read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        env[key.strip()] = value.strip()
    for required in ("PROJECT_NAME", "VERSION"):
        if not env.get(required):
            raise SystemExit(f"project.env: {required} is not set")
    repo = env.get("GITHUB_REPO", "")
    if "/" in repo:
        owner, name = repo.split("/", 1)
        env["REPO_OWNER"], env["REPO_NAME"] = owner, name
        env["REPO_URL"] = f"https://github.com/{repo}"
        env["SITE_URL"] = f"https://{owner}.github.io/{name}/"
    else:
        env["REPO_URL"] = "https://github.com/"
        env["SITE_URL"] = "http://localhost:8000/"
    env["SITE_NAME"] = env["PROJECT_NAME"]
    return env


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--github-env":
        for k, v in load().items():
            print(f"{k}={v}")
    elif len(sys.argv) == 2:
        print(load().get(sys.argv[1], ""))
    else:
        print(__doc__)
