#!/usr/bin/env python3

import json
import shutil
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]

OLD_NAME = "SillyTavern"
OLD_LOWER = "sillytavern"

NEW_NAME = "SarVita Arc"
NEW_SLUG = "sarvita-arc"

BACKUP_DIR = ROOT / "tools" / "branding" / "backup-before-rename"


def backup(path):
    if not path.exists():
        return

    target = BACKUP_DIR / path.relative_to(ROOT)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, target)


def write_text(path, text):
    backup(path)
    path.write_text(text, encoding="utf-8")


def update_package_json():
    path = ROOT / "package.json"

    with path.open(encoding="utf-8") as f:
        data = json.load(f)

    changed = False

    if data.get("name") == OLD_LOWER:
        data["name"] = NEW_SLUG
        changed = True

    if changed:
        backup(path)

        with path.open("w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
            f.write("\n")

        print("[OK] package.json project name ->", NEW_SLUG)
    else:
        print("[SKIP] package.json name already changed or not found")


def update_package_lock():
    path = ROOT / "package-lock.json"

    if not path.exists():
        print("[SKIP] package-lock.json not found")
        return

    with path.open(encoding="utf-8") as f:
        data = json.load(f)

    changed = False

    if data.get("name") == OLD_LOWER:
        data["name"] = NEW_SLUG
        changed = True

    packages = data.get("packages")

    if isinstance(packages, dict):
        root_package = packages.get("")

        if isinstance(root_package, dict):
            if root_package.get("name") == OLD_LOWER:
                root_package["name"] = NEW_SLUG
                changed = True

    if changed:
        backup(path)

        with path.open("w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")

        print("[OK] package-lock.json root name ->", NEW_SLUG)
    else:
        print("[SKIP] package-lock.json root identity unchanged")


def update_index():
    path = ROOT / "public" / "index.html"

    if not path.exists():
        print("[SKIP] public/index.html not found")
        return

    text = path.read_text(encoding="utf-8")

    original = text

    text = text.replace(
        "<title>SillyTavern</title>",
        "<title>SarVita Arc</title>"
    )

    text = text.replace(
        "Welcome to SillyTavern!",
        "Welcome to SarVita Arc!"
    )

    text = text.replace(
        "SillyTavern is aimed at advanced users.",
        "SarVita Arc is aimed at advanced users."
    )

    if text != original:
        write_text(path, text)
        print("[OK] public/index.html branding updated")
    else:
        print("[SKIP] public/index.html no target branding found")


def update_arabic_translation():
    path = ROOT / "public" / "locales" / "ar-sa.json"

    if not path.exists():
        print("[SKIP] Arabic locale not found")
        return

    with path.open(encoding="utf-8") as f:
        data = json.load(f)

    def process(obj):
        if isinstance(obj, dict):
            return {k: process(v) for k, v in obj.items()}

        if isinstance(obj, list):
            return [process(v) for v in obj]

        if isinstance(obj, str):
            obj = obj.replace("SillyTavern", NEW_NAME)
            obj = obj.replace("sillytavern", NEW_SLUG)
            return obj

        return obj

    new_data = process(data)

    backup(path)

    with path.open("w", encoding="utf-8") as f:
        json.dump(new_data, f, ensure_ascii=False, indent=4)
        f.write("\n")

    print("[OK] Arabic branding updated")


def main():
    print("=" * 50)
    print(" SarVita Arc - SAFE BRAND RENAME")
    print("=" * 50)
    print()

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    update_package_json()
    update_package_lock()
    update_index()
    update_arabic_translation()

    print()
    print("=" * 50)
    print(" Rename phase completed")
    print("=" * 50)
    print()
    print("Backup directory:")
    print(BACKUP_DIR)


if __name__ == "__main__":
    main()
