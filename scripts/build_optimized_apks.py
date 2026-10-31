import os
import subprocess
import sys

def run_command(cmd, cwd):
    print(f"Executing: {' '.join(cmd)}")
    res = subprocess.run(cmd, cwd=cwd, shell=True)
    if res.returncode != 0:
        print(f"Error executing command: {' '.join(cmd)}")
        sys.exit(res.returncode)

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    flutter_dir = os.path.join(root, "flutter_app")
    symbols_dir = os.path.join(flutter_dir, "build", "app", "outputs", "symbols")
    apk_dir = os.path.join(flutter_dir, "build", "app", "outputs", "flutter-apk")

    print("=== Building Optimized Release APKs for Movie Imposter ===")

    # 1. Build Split-per-ABI APKs (Ultra-lightweight ~13-16MB)
    split_cmd = [
        "flutter", "build", "apk", "--release",
        "--split-per-abi",
        "--obfuscate",
        f"--split-debug-info={symbols_dir}",
    ]
    run_command(split_cmd, flutter_dir)

    # 2. Build Universal Fat APK (~45MB)
    universal_cmd = [
        "flutter", "build", "apk", "--release",
        "--obfuscate",
        f"--split-debug-info={symbols_dir}",
    ]
    run_command(universal_cmd, flutter_dir)

    print("\n=== Copying to Release Asset Names ===")
    copy_map = {
        "app-arm64-v8a-release.apk": "movie-imposter.apk",
        "app-release.apk": "movie-imposter-universal.apk",
        "app-armeabi-v7a-release.apk": "movie-imposter-armeabi-v7a.apk",
        "app-x86_64-release.apk": "movie-imposter-x86_64.apk",
    }
    import shutil
    for src_name, dst_name in copy_map.items():
        src_path = os.path.join(apk_dir, src_name)
        dst_path = os.path.join(apk_dir, dst_name)
        if os.path.exists(src_path):
            shutil.copyfile(src_path, dst_path)
            print(f"  Copied {src_name} -> {dst_name}")

    print("\n=== Build Complete! Generated APKs: ===")
    if os.path.exists(apk_dir):
        for f in sorted(os.listdir(apk_dir)):
            if f.endswith(".apk"):
                p = os.path.join(apk_dir, f)
                size_mb = os.path.getsize(p) / (1024 * 1024)
                print(f"  - {f:35} : {size_mb:.1f} MB")

if __name__ == "__main__":
    main()
