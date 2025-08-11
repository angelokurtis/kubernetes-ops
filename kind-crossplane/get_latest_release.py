#!/usr/bin/env python3
import sys
import json
import requests

# Read input
input_data = json.load(sys.stdin)
repo = input_data.get("repo", "hashicorp/terraform")

# Fetch latest release from GitHub API
url = f"https://api.github.com/repos/{repo}/releases/latest"
resp = requests.get(url)
data = resp.json()

print(json.dumps({
    "tag_name": data.get("tag_name", ""),
    "name": data.get("name", ""),
    "published_at": data.get("published_at", "")
}))
