# PulseCN 上游同步维护指南

这份文档用于说明：**当原始 Pulse 仓库继续更新后，如何把更新安全地同步到 `PulseCN`，同时尽量减少中文本地化冲突。**

## 当前维护策略

`PulseCN` 现在采用的是**资源本地化**方案，而不是直接把英文字符串硬改为中文：

- `PulseUI` 代码使用 `L10n.tr(...)` / `L10n.fmt(...)`
- 英文保留在 `Sources/PulseUI/Resources/en.lproj/Localizable.strings`
- 中文放在 `Sources/PulseUI/Resources/zh-Hans.lproj/Localizable.strings`

这意味着以后同步上游时，你的主要维护点只有两类：

1. 上游新增或修改了 UI 文案对应的 Swift 代码
2. 上游新增了新的用户可见字符串，需要补 key 与翻译

这比“整仓替换为中文”要稳定得多。

---

## 一次标准同步流程

建议每次都按下面顺序执行。

### 1) 添加并确认 upstream

如果还没有配置上游仓库：

```bash
git remote add upstream https://github.com/kean/Pulse.git
```

查看远程：

```bash
git remote -v
```

你应该至少看到：

- `origin` → 你的 `PulseCN`
- `upstream` → 原始 `Pulse`

---

### 2) 拉取上游最新改动

```bash
git fetch upstream
```

如果你平时就在 `main` 上维护：

```bash
git checkout main
git merge upstream/main
```

如果你更喜欢保持历史整洁，也可以：

```bash
git checkout main
git rebase upstream/main
```

> 如果已经推送过自己的提交，且不熟悉 rebase，优先用 `merge`，更稳。

---

### 3) 先解决代码冲突，再处理翻译

同步时，最常见的冲突点是：

- `Sources/PulseUI/...` 某些 SwiftUI 文件被上游修改了
- 这些文件在 `PulseCN` 中又已经接入了 `L10n.tr(...)`

处理原则：

- **保留上游的新逻辑 / 新布局 / 新结构**
- **保留 PulseCN 的本地化接法**（即继续走 key，而不是退回硬编码英文）
- 如果上游新增了文案，优先接成新的 localization key

一句话：

> **上游负责功能结构，PulseCN 负责本地化层。**

---

### 4) 扫描新增英文 UI 文案

同步完成后，不要立刻结束；要再扫一遍有没有新增的硬编码英文文案。

重点排查：

- `Text("...")`
- `Label("...")`
- `Button("...")`
- `navigationTitle("...")`
- `Section("...")`
- `Picker("...")`
- `SecureField("...")`
- `PlaceholderView(title: "...")`

如果发现新增英文文案：

1. 给它补一个新的 `pulse.xxx.xxx` key
2. 在 Swift 代码里改成 `L10n.tr(...)` 或 `L10n.fmt(...)`
3. 同时补 `en.lproj` 和 `zh-Hans.lproj`

---

### 5) 新增文案时的 key 规则

建议继续沿用现在的命名方式：

- `pulse.common.*`：通用按钮 / 常见词
- `pulse.console.*`：控制台
- `pulse.filters.*`：筛选器
- `pulse.network.*`：网络检查器
- `pulse.remote.*`：远程日志
- `pulse.sessions.*`：会话
- `pulse.settings.*`：设置
- `pulse.store.*`：存储信息
- `pulse.details.*`：详情页字段名
- `pulse.error.*`：用户可见错误描述

这样做的好处是：

- 后续查找更快
- 冲突更集中
- 容易判断新文案应该落在哪个模块

---

## 推荐的每次同步检查清单

每次同步完成后，至少检查下面几项：

### 构建检查

```bash
swift build
```

### Demo 构建检查

```bash
xcodebuild -project "Demo/Pulse.xcodeproj" -scheme "Pulse Demo iOS" -destination 'generic/platform=iOS Simulator' build
```

### 语言资源检查

确认以下资源仍然存在：

- `Sources/PulseUI/Resources/en.lproj/Localizable.strings`
- `Sources/PulseUI/Resources/zh-Hans.lproj/Localizable.strings`

### 运行验证

在中文环境下重点检查这些区域：

- Console
- Filters
- Sessions
- Settings
- Network Inspector
- Share / Context Menus
- Remote Logging

同时也要切回英文看一遍，确认没有把默认英文破坏掉。

---

## 推荐的提交策略

同步上游后，建议把自己的本地化修复继续拆成小提交，例如：

1. `Merge upstream/main`
2. `Expand PulseUI localization catalog`
3. `Localize console and filter actions`
4. `Localize inspector and detail views`

这样做的好处：

- 出问题时更容易回滚
- 将来再次同步上游时更容易定位冲突来源
- 方便你自己审查“这次上游更新到底影响了哪些中文内容”

---

## 什么时候不要直接翻译

下面这些内容不一定要强行翻译：

- 纯调试预览文案
- 技术缩写（例如某些协议名、TLS cipher suite）
- 代码常量名、系统原始枚举值

判断原则：

> **用户真的会在界面上看到并依赖它理解功能时，再优先本地化。**

---

## 建议的长期维护原则

长期来看，`PulseCN` 最稳的维护方式是：

- **尽量少改功能逻辑**
- **尽量把改动限制在本地化接线层与 `.strings` 文件**
- **优先跟上游结构走，不自己分叉出另一套 UI 逻辑**

这样以后每次同步，工作量基本都会收敛成：

1. 合并上游
2. 解决少量冲突
3. 扫描新增英文文案
4. 补翻译
5. 验证构建

---

## 一个最小示例流程

```bash
git checkout main
git fetch upstream
git merge upstream/main

# 解决冲突

# 扫描新增硬编码英文文案
# 补 L10n key 与 en/zh-Hans strings

swift build
xcodebuild -project "Demo/Pulse.xcodeproj" -scheme "Pulse Demo iOS" -destination 'generic/platform=iOS Simulator' build
```

如果你希望后续维护更省心，建议每次上游更新后都重复这套流程，而不是攒很多版本再一次性同步。
