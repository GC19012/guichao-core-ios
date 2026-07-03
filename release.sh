#!/usr/bin/env bash
# 用法: ./release.sh <version> <path-to-GuiChaoCore.xcframework>
# 例如: ./release.sh 3.1.9 ~/Desktop/guichaoapp_0611/ios/Frameworks/GuiChaoCore.xcframework
set -euo pipefail

VERSION="${1:?用法: release.sh <version> <xcframework-path>}"
XCFRAMEWORK_SRC="${2:?用法: release.sh <version> <xcframework-path>}"
GITHUB_ORG="GC19012"
GITHUB_REPO="guichao-core-ios"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -d "$XCFRAMEWORK_SRC" ]]; then
  echo "❌ 找不到 xcframework: $XCFRAMEWORK_SRC"
  exit 1
fi

ZIP_NAME="GuiChaoCore.xcframework.zip"
rm -f "$ZIP_NAME"

echo "▶ 打包 xcframework"
# 用 ditto 而不是 zip，正确保留 xcframework 内部结构（framework bundle）
ditto -c -k --sequesterRsrc --keepParent "$XCFRAMEWORK_SRC" "$ZIP_NAME"

echo "▶ 计算 checksum"
CHECKSUM=$(swift package compute-checksum "$ZIP_NAME")
echo "checksum: $CHECKSUM"

echo "▶ 更新 Package.swift"
DOWNLOAD_URL="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/releases/download/${VERSION}/${ZIP_NAME}"
python3 - "$DOWNLOAD_URL" "$CHECKSUM" << 'EOF'
import re, sys
url, checksum = sys.argv[1], sys.argv[2]
with open("Package.swift") as f:
    content = f.read()
content = re.sub(r'url: "[^"]*"', f'url: "{url}"', content)
content = re.sub(r'checksum: "[^"]*"', f'checksum: "{checksum}"', content)
with open("Package.swift", "w") as f:
    f.write(content)
EOF

echo "▶ git commit + tag"
git add Package.swift
git commit -m "release: GuiChaoCore ${VERSION}"
git tag "${VERSION}"

echo ""
echo "✅ 本地准备完成。接下来手动操作："
echo "  1. git push && git push origin ${VERSION}"
echo "  2. 去 GitHub 仓库 Releases 页面，基于 tag ${VERSION} 创建 Release"
echo "  3. 把 ${ZIP_NAME} 作为 Release 资产上传"
echo ""
echo "下载地址（供核对）: ${DOWNLOAD_URL}"
