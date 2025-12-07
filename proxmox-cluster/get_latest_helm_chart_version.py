#!/usr/bin/env python3
import sys
import json
import urllib.request
import yaml
import os
import time
import tempfile
from datetime import datetime
from packaging.version import Version
from packaging.specifiers import SpecifierSet

# -------------------------
# Configuration
# -------------------------
CACHE_TTL_SECONDS = 86400  # 24 hours
CACHE_DIR = os.path.join(tempfile.gettempdir(), "terraform-helm-cache")
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
def cache_key(repo_url, chart_name, constraint):
    safe_repo = repo_url.replace("https://", "").replace("http://", "").replace("/", "_")
    safe_chart = chart_name.replace("/", "_")
    spec = constraint.replace(" ", "").replace(",", "_") if constraint else "any"
    return os.path.join(CACHE_DIR, f"{safe_repo}_{safe_chart}_{spec}.json")

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

    repo_url = input_data["repo"].rstrip("/")
    chart_name = input_data["chart"]
    constraint = input_data.get("semver", "")
    spec = SpecifierSet(constraint)

    log("INFO", f"Resolving latest Helm chart version for repo={repo_url}, chart={chart_name}, semver='{constraint}'")

    cache_path = cache_key(repo_url, chart_name, constraint)

    # 1. Try cache
    cached = load_cache(cache_path)
    if cached:
        print(json.dumps(cached))
        return

    # 2. Fetch index.yaml
    index_url = f"{repo_url}/index.yaml"
    log("DEBUG", f"Fetching Helm index: {index_url}")

    try:
        with urllib.request.urlopen(index_url, timeout=15) as resp:
            data = resp.read().decode("utf-8")
    except Exception as e:
        log("ERROR", f"Failed to fetch Helm index: {e}")
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

    index = yaml.safe_load(data)

    if chart_name not in index.get("entries", {}):
        err = f"Chart '{chart_name}' not found in {index_url}"
        log("ERROR", err)
        print(json.dumps({"error": err}))
        sys.exit(1)

    valid_versions = []
    for entry in index["entries"][chart_name]:
        version_str = entry.get("version")
        try:
            version = Version(version_str)
            if version in spec:
                valid_versions.append((version, entry))
        except Exception:
            log("DEBUG", f"Skipping invalid version: {version_str}")

    if not valid_versions:
        err = f"No valid chart versions found for constraint '{constraint}'"
        log("ERROR", err)
        print(json.dumps({"error": err}))
        sys.exit(1)

    valid_versions.sort(reverse=True)
    latest_version, latest_entry = valid_versions[0]

    result = {
        "version": latest_entry["version"],
        "chart": chart_name,
        "repo": repo_url,
        "constraint": constraint
    }

    log("INFO", f"Resolved latest chart version: {latest_entry['version']}")

    # 3. Persist cache
    write_cache(cache_path, result)

    # 4. Emit JSON for Terraform
    print(json.dumps(result))


if __name__ == "__main__":
    main()
