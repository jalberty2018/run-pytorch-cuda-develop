#!/usr/bin/env python3
import os
import sys
import requests
from pathlib import Path
from urllib.parse import urlparse, parse_qs

API_BASE = "https://civitai.com/api/v1/model-versions"

def get_filename_from_response(response, fallback):
    cd = response.headers.get("content-disposition", "")
    if "filename=" in cd:
        return cd.split("filename=")[-1].strip('"')
    return fallback

def download_model(version_id, dest_dir):
    api_key = os.environ.get("CIVITAI_TOKEN")
    if not api_key:
        raise SystemExit("❌ No CIVITAI_TOKEN environment variable set.")

    dest = Path(dest_dir)
    dest.mkdir(parents=True, exist_ok=True)

    meta_url = f"{API_BASE}/{version_id}"
    headers = {"Authorization": f"Bearer {api_key}"}

    print(f"ℹ️ Downloading Metadata for modelVersionId={version_id}")
    meta = requests.get(meta_url, headers=headers, timeout=30)
    meta.raise_for_status()
    data = meta.json()

    download_url = data.get("downloadUrl")
    if not download_url:
        raise SystemExit("❌ No downloadUrl found.")

    # Token als query parameter werkt vaak het betrouwbaarst voor downloads
    sep = "&" if "?" in download_url else "?"
    download_url = f"{download_url}{sep}token={api_key}"

    fallback_name = f"civitai_{version_id}.safetensors"

    print("▶️ Start download ...")
    with requests.get(download_url, stream=True, timeout=60) as r:
        r.raise_for_status()

        filename = get_filename_from_response(r, fallback_name)
        target = dest / filename
        tmp = dest / f"{filename}.part"

        if target.exists() and target.stat().st_size > 0:
            print(f"⚠️ SKIP: File exists: {target}")
            return

        total = int(r.headers.get("content-length", 0))
        downloaded = 0

        with open(tmp, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total:
                        pct = downloaded * 100 / total
                        print(f"\r{pct:.1f}%  {downloaded/1024/1024:.1f} MB", end="")

        tmp.rename(target)
        print(f"\n✅ Ready: {target}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage:")
        print("  civitai_com VERSION_ID DEST_DIR")
        print()
        print("Example:")
        print("  civitai_com 2893442 /workspace/ComfyUI/models/loras")
        sys.exit(1)

    download_model(sys.argv[1], sys.argv[2])