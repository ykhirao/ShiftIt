#!/bin/bash
# Xcode がなくても、Command Line Tools の clang でソースを構文チェックする（リンクと xib のコンパイルはしない）。
# 最終的な確認は CI のビルドで行う。
#   scripts/check-syntax.sh
set -u
cd "$(dirname "$0")/.."
ROOT=$PWD/ShiftIt

# ShortcutRecorder のヘッダ。バージョンは project.yml の packages と合わせる
SR_VERSION=$(sed -n 's/^ *exactVersion: *//p' project.yml | head -1)
SR_DIR=$PWD/build/ShortcutRecorder-$SR_VERSION
if [ ! -d "$SR_DIR" ]; then
  git clone -q --depth 1 --branch "$SR_VERSION" https://github.com/Kentzo/ShortcutRecorder "$SR_DIR" 2>/dev/null
fi
SR_INCLUDE=$SR_DIR/Sources/ShortcutRecorder/include
SDK=$(xcrun --show-sdk-path)

fail=0
for f in $(cd "$ROOT" && ls *.m FMT/*.m GTM/*.m | grep -v GHUnitTestMain); do
  arc=-fobjc-arc
  case $f in GTM/*) arc=-fno-objc-arc ;; esac
  out=$(clang -fsyntax-only $arc -fmodules -fobjc-exceptions -arch arm64 -isysroot "$SDK" -mmacosx-version-min=13.0 \
    -DNDEBUG=1 -include "$ROOT/ShiftIt_Prefix.pch" -I"$ROOT" -I"$ROOT/FMT" -I"$ROOT/GTM" -I"$SR_INCLUDE" \
    -Wall -Wimplicit-retain-self -Werror=incompatible-pointer-types -Werror=implicit-function-declaration \
    "$ROOT/$f" 2>&1)
  if echo "$out" | grep -q "error:"; then
    fail=1
  fi
  echo "$out" | grep -E "(error|warning):" | sed "s#$ROOT/##"
done

if [ $fail = 0 ]; then
  echo "OK"
else
  exit 1
fi
