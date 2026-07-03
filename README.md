# guichao-core-ios

![License](https://img.shields.io/badge/license-Proprietary-red)

GuiChaoCore（Go 编译产物）打包为 Swift 二进制 `.xcframework`，通过 Swift
Package Manager 分发给 GUICHAO iOS App 使用。

Go 源码不在本仓库内，本仓库只承载 SwiftPM 分发描述
（`Package.swift`）与发布脚本；真正的 `.xcframework` 二进制不进入 git
历史，随每次发布上传为 GitHub Release 资产。

## Layout

```
Package.swift     远程 binaryTarget(url:, checksum:)，指向对应 tag 的
                  Release 资产
release.sh        一键发布脚本：打包 → 计算 checksum → 更新
                  Package.swift → commit + tag
```

## Consuming from an Xcode project

```swift
.package(url: "git@github.com:GC19012/guichao-core-ios.git", from: "3.1.8")
```

或者在 Xcode 里 File > Add Package Dependencies，直接粘贴上面的仓库地址，
版本规则选 "Up to Next Major"，起始版本 `3.1.8`。

对应 tag 的 `Package.swift` 里声明的是 `binaryTarget(url:, checksum:)`，
SwiftPM 会下载 Release 资产并用 SHA256 校验完整性。

## How releases happen

发布是手动触发的（Go 核心的编译产物不在本仓库，无法像纯 Go 依赖那样自动
探测上游版本变化）：

```bash
./release.sh 3.1.9 /path/to/new/GuiChaoCore.xcframework
```

脚本依次完成：
1. `ditto` 打包 xcframework 为 zip（保留 framework bundle 结构）
2. `swift package compute-checksum` 计算 SHA256
3. 更新 `Package.swift` 里的 `url` / `checksum`
4. `git commit` + 打 tag（与即将创建的 GitHub Release tag 一致）

脚本跑完后需要手动：
```bash
git push && git push origin <version>
```
然后在 GitHub 仓库 Releases 页面基于该 tag 创建 Release，把生成的 zip
作为资产上传。

## 私有仓库访问配置（如果之后把仓库切成私有）

当前仓库是**公开**的，SwiftPM 直接下载 Release 资产不需要任何认证。

如果之后决定把仓库/Release 设为私有，SwiftPM 下载二进制资产就需要认证，
在 `~/.netrc` 里加一条（token 需要对该仓库的 Contents 读权限）：

```
machine github.com
login <your-github-username>
password <personal-access-token>
```

不需要改 `Package.swift` 结构，只是多这一步配置。

## License

私有闭源，详见 [LICENSE](LICENSE)。分发的二进制仅供 GUICHAO 自身 App
使用，不授予任何复制、修改、逆向工程或再分发权利。
