#!/usr/bin/env python3

import argparse
import shlex
import subprocess
import sys
from pathlib import Path

import yaml


ARM_CONFIG = Path("/home/arm/config/arm.yaml")


def load_config():
    if not ARM_CONFIG.exists():
        raise FileNotFoundError(f"ARM config not found: {ARM_CONFIG}")

    with ARM_CONFIG.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def find_mkv_files(input_dir: Path):
    return sorted(
        p for p in input_dir.rglob("*")
        if p.is_file() and p.suffix.lower() == ".mkv"
    )


def print_tree(paths, existing):
    tree = {}
    for rel in paths:
        node = tree
        for part in rel.parts[:-1]:
            node = node.setdefault(part + "/", {})
        node[rel.parts[-1]] = rel

    def walk(node, prefix):
        items = sorted(node.items(), key=lambda kv: (not isinstance(kv[1], dict), kv[0]))
        for i, (name, child) in enumerate(items):
            last = i == len(items) - 1
            label = name
            if not isinstance(child, dict) and child in existing:
                label += "  [output exists - SKIP]"
            print(f"{prefix}{'└── ' if last else '├── '}{label}")
            if isinstance(child, dict):
                walk(child, prefix + ("    " if last else "│   "))

    print(".")
    walk(tree, "")


def build_command(config, source: Path, destination: Path):
    preset = config.get("HB_PRESET_BD")
    hb_args = config.get("HB_ARGS_BD", "")
    handbrake = config.get("HANDBRAKE_CLI", "HandBrakeCLI")

    if not preset:
        raise ValueError("HB_PRESET_BD is not defined in ARM config")

    args = [
        handbrake,
        "--preset",
        preset,
        "-i",
        str(source),
        "-o",
        str(destination),
    ]

    # Parse the ARM YAML argument string exactly like a shell command line,
    # but without actually invoking a shell.
    args.extend(shlex.split(hb_args))

    return args


def encode_file(config, source: Path, destination: Path):
    destination.parent.mkdir(parents=True, exist_ok=True)

    command = build_command(config, source, destination)

    print()
    print("=" * 80)
    print(f"Input : {source}")
    print(f"Output: {destination}")
    print()
    print("Command:")
    print(" ".join(shlex.quote(x) for x in command))
    print("=" * 80)

    result = subprocess.run(command)

    if result.returncode != 0:
        raise RuntimeError(
            f"HandBrake failed with exit code {result.returncode}: {source}"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Encode ARM Blu-ray rips using the HandBrake settings from arm.yaml."
    )

    parser.add_argument(
        "input",
        type=Path,
        help="Directory containing ripped Blu-ray MKVs",
    )

    parser.add_argument(
        "output",
        type=Path,
        help="Output directory for encoded files",
    )

    parser.add_argument(
        "-y",
        action="store_true",
        help="Proceed without asking for confirmation",
    )

    args = parser.parse_args()

    input_dir = args.input.resolve()
    output_dir = args.output.resolve()

    if not input_dir.is_dir():
        print(f"ERROR: Input directory does not exist: {input_dir}")
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)

    try:
        config = load_config()
    except Exception as e:
        print(f"ERROR: Could not load ARM config: {e}")
        sys.exit(1)

    preset = config.get("HB_PRESET_BD")
    hb_args = config.get("HB_ARGS_BD", "")
    handbrake = config.get("HANDBRAKE_CLI", "HandBrakeCLI")

    print(f"ARM config : {ARM_CONFIG}")
    print(f"HandBrake  : {handbrake}")
    print(f"BD preset  : {preset}")
    print(f"BD args    : {hb_args}")
    print(f"Input      : {input_dir}")
    print(f"Output     : {output_dir}")

    files = find_mkv_files(input_dir)

    if not files:
        print("No MKV files found.")
        return

    print(f"\nFound {len(files)} MKV file(s) in {input_dir}:\n")

    relatives = [f.relative_to(input_dir) for f in files]
    existing = {r for r in relatives if (output_dir / r).with_suffix(".mkv").exists()}
    print_tree(relatives, existing)

    print(f"\nTarget output folder: {output_dir}")
    if existing:
        print(
            f"{len(existing)} output file(s) already exist and will be SKIPPED "
            "(not overwritten)."
        )
    print("No files will be overwritten.")

    if len(existing) == len(files):
        print("Nothing to encode.")
        return

    if not args.y:
        try:
            answer = input("\nProceed with batch encode? [y/N] ").strip().lower()
        except EOFError:
            answer = ""
        if answer not in ("y", "yes"):
            print("Aborted.")
            return

    for index, source in enumerate(files, start=1):
        relative = source.relative_to(input_dir)
        destination = output_dir / relative

        # Keep the same filename. The source is already MKV and HandBrake
        # will overwrite/create the destination as specified.
        destination = destination.with_suffix(".mkv")

        print()
        print(f"[{index}/{len(files)}]")

        if destination.exists():
            print(f"SKIP: Output already exists:")
            print(f"      {destination}")
            continue

        try:
            encode_file(config, source, destination)
        except Exception as e:
            print(f"\nERROR: {e}")
            print("Aborting remaining encodes.")
            sys.exit(1)

    print()
    print("=" * 80)
    print("All encodes completed.")
    print("=" * 80)


if __name__ == "__main__":
    main()