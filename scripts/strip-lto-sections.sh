#!/usr/bin/env bash
# Removes the LLVM LTO sections from the prebuilt deps/*/libzen_ffi.a archives.
# go1.27.4 and later refuse a #cgo LDFLAGS archive that carries them
# ("disallowed LTO section"). The archives link without them.
set -euo pipefail

cd "$(dirname "$0")/.."

objcopy=${OBJCOPY:-llvm-objcopy}
if ! command -v "$objcopy" >/dev/null 2>&1; then
  echo "strip-lto-sections: $objcopy not found, set OBJCOPY" >&2
  exit 1
fi

shopt -s nullglob
archives=(deps/*/libzen_ffi.a)
if [ "${#archives[@]}" -eq 0 ]; then
  echo "strip-lto-sections: no deps/*/libzen_ffi.a found" >&2
  exit 1
fi

for archive in "${archives[@]}"; do
  case "$archive" in
    deps/darwin_*)
      "$objcopy" -R __LLVM,__bitcode -R __LLVM,__cmdline -R __LLVM,__asm "$archive"
      ;;
    *)
      "$objcopy" -R .llvmbc -R .llvmcmd "$archive"
      ;;
  esac
  echo "stripped $archive"
done
