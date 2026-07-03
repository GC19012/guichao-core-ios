# guichao-core-ios

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

## 私有仓库访问配置（消费方机器/CI 都需要）

仓库私有时，SwiftPM 下载 Release 二进制资产需要认证，在
`~/.netrc` 里加一条（token 需要 `repo` 权限）：

```
machine github.com
login <your-github-username>
password <personal-access-token>
```

如果之后决定把仓库/Release 设为公开，直接改可见性即可，不需要动
`Package.swift` 结构，只是可以省掉这一步。
