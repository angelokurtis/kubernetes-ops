#!/usr/bin/env python3
import sys
import json
import requests
import os
import time
import tempfile
from packaging.version import Version
from packaging.specifiers import SpecifierSet
from datetime import datetime

# -------------------------
# Configuration
# -------------------------
CACHE_TTL_SECONDS = 86400  # 24 hours
CACHE_DIR = os.path.join(tempfile.gettempdir(), "terraform-github-cache")
os.makedirs(CACHE_DIR, exist_ok=True)

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()

# -------------------------
# Logging
# -------------------------
def log(level, msg):
    levels = ["DEBUG", "INFO", "WARN", "ERROR"]
    if levels.index(level) >= levels.index(LOG_LEVEL):
        ts = datetime.utcnow().isoformat()
        print(f"[{ts}] [{level}] {msg}", file=sys.stderr)

# -------------------------
# Helpers
# -------------------------
def cache_key(repo, constraint):
    safe = repo.replace("/", "_")
    spec = constraint.replace(" ", "").replace(",", "_")
    return os.path.join(CACHE_DIR, f"{safe}_{spec}.json")

def load_cache(path):
    if not os.path.exists(path):
        log("DEBUG", f"Cache miss (no file): {path}")
        return None

    try:
        with open(path) as f:
            cached = json.load(f)

        age = time.time() - cached["timestamp"]
        ttl = CACHE_TTL_SECONDS

        if age < ttl:
            log("INFO", f"Cache hit ({int(age)}s old): {path}")
            return cached["data"]

        log("INFO", f"Cache expired ({int(age)}s > {ttl}s): {path}")
    except Exception as e:
        log("WARN", f"Cache read failed: {e}")

    return None

def write_cache(path, data):
    tmp = f"{path}.tmp"

    log("INFO", f"Writing cache file: {path}")
    with open(tmp, "w") as f:
        json.dump(
            {
                "timestamp": time.time(),
                "data": data
            },
            f,
            indent=2
        )
    os.replace(tmp, path)

# -------------------------
# Main
# -------------------------
def main():
    input_data = json.load(sys.stdin)

    repo = input_data.get("repo", "hashicorp/terraform")
    constraint = input_data.get("semver", "")
    spec = SpecifierSet(constraint)

    log("INFO", f"Resolving latest tag for repo={repo} constraint='{constraint}'")

    cache_path = cache_key(repo, constraint)

    # 1. Try cache first
    cached = load_cache(cache_path)
    if cached:
        print(json.dumps(cached))
        return

    # 2. Build GitHub request
    headers = {
        "Accept": "application/vnd.github+json"
    }

    # Optional GitHub token (recommended)
    token = os.getenv("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
        log("DEBUG", "Using GITHUB_TOKEN for authentication")
    else:
        log("WARN", "No GITHUB_TOKEN set; using unauthenticated GitHub API")

    tags = []
    page = 1
    per_page = 100

    while True:
        url = f"https://api.github.com/repos/{repo}/tags?per_page={per_page}&page={page}"
        log("DEBUG", f"Fetching: {url}")

        resp = requests.get(url, headers=headers, timeout=15)

        # Explicit rate-limit failure
        if resp.status_code == 403:
            raise RuntimeError(
                "GitHub API rate limit exceeded. "
                "Set GITHUB_TOKEN to increase limits."
            )

        resp.raise_for_status()
        data = resp.json()

        if not data:
            break

        tags.extend(tag["name"] for tag in data)

        if len(data) < per_page:
            break

        page += 1

    log("INFO", f"Fetched {len(tags)} tags from GitHub")

    valid = []
    for tag in tags:
        norm = tag.lstrip("vV")
        try:
            v = Version(norm)
            if v in spec:
                valid.append((v, tag))
        except Exception:
            log("DEBUG", f"Skipping invalid tag: {tag}")

    if not valid:
        err = f"No valid versions found for constraint '{constraint}'"
        log("ERROR", err)
        print(json.dumps({"error": err}))
        sys.exit(1)

    valid.sort(reverse=True)
    latest_version, latest_tag = valid[0]

    result = {
        "tag_name": latest_tag,
        "normalized_tag": str(latest_version),
        "constraint": constraint,
        "repo": repo
    }

    log(
        "INFO",
        f"Resolved latest version: {latest_tag} (normalized {latest_version})"
    )

    # 3. Persist cache
    write_cache(cache_path, result)

    # 4. Emit for Terraform
    print(json.dumps(result))


if __name__ == "__main__":
    main()
