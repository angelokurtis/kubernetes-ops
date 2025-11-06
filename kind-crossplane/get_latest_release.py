#!/usr/bin/env python3
import sys
import json
import requests
import re

def is_valid_semver(version):
    pattern = r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)' \
              r'(?:-[\da-z\-]+(?:\.[\da-z\-]+)*)?' \
              r'(?:\+[\da-z\-]+(?:\.[\da-z\-]+)*)?$'
    return re.match(pattern, version, re.IGNORECASE) is not None

def semver_key(version):
    # Split by dot or dash for sorting, supports pre-release and build
    parts = re.split(r'[.-]', version)
    return [int(p) if p.isdigit() else p for p in parts]

def main():
    input_data = json.load(sys.stdin)
    repo = input_data.get("repo", "hashicorp/terraform")

    tags = []
    page = 1
    per_page = 100
    while True:
        url = f"https://api.github.com/repos/{repo}/tags?per_page={per_page}&page={page}"
        resp = requests.get(url)
        resp.raise_for_status()
        data = resp.json()
        if not data:
            break
        tags.extend([tag['name'] for tag in data])
        if len(data) < per_page:
            break
        page += 1

    # Filter and normalize semver tags
    semver_tags = []
    for tag in tags:
        norm_tag = tag.lstrip("vV")
        if is_valid_semver(norm_tag):
            semver_tags.append((norm_tag, tag))

    if not semver_tags:
        print(json.dumps({"error": "No valid semver tags found"}))
        sys.exit(1)

    # Sort semver descending
    semver_tags.sort(key=lambda x: semver_key(x[0]), reverse=True)
    latest_norm, latest_tag = semver_tags[0]

    print(json.dumps({
        "tag_name": latest_tag,
        "normalized_tag": latest_norm,
    }))

if __name__ == "__main__":
    main()
