<br/>
<img width="2100" alt="01" src="https://user-images.githubusercontent.com/1567433/184552586-dd8cce3a-7ae1-494d-bbe9-41cfb1617c50.png">

**Pulse** 是一个面向 Apple 平台的强大日志系统。原生实现，基于 SwiftUI 构建。

你可以直接在 iOS App 中记录并查看日志与 `URLSession` 网络请求；还可以分享日志、在 [Pulse Pro](https://kean.blog/pulse/pro) 中查看，或者使用远程日志实时观察。所有日志默认都存储在本地，不会离开你的设备。

## Sponsors 💖

虽然你可以免费使用 Pulse 和 Pulse Pro，但如果它对你有帮助，欢迎通过 GitHub Sponsors [支持项目](https://github.com/sponsors/kean)。

<a target="_blank" rel="noopener noreferrer" href="https://getstream.io/chat/sdk/swiftui/?utm_source=Github&utm_medium=github_repo_content_ad&utm_content=Developer&utm_campaign=Pulse_October2022_SwiftUI_klmh22#gh-light-mode-only"><img src="https://user-images.githubusercontent.com/1567433/175186173-64eb53cb-b5d6-4ed4-aaca-87dbbb0834ab.png#gh-light-mode-only" width="300px" alt="Stream Logo" style="max-width: 100%;"></a>
<a target="_blank" rel="noopener noreferrer" href="https://getstream.io/chat/sdk/swiftui/?utm_source=Github&utm_medium=github_repo_content_ad&utm_content=Developer&utm_campaign=Pulse_October2022_SwiftUI_klmh22#gh-dark-mode-only"><img src="https://user-images.githubusercontent.com/1567433/175562043-0ab82adc-e3c7-4c0b-8813-a7940ff41db8.png#gh-dark-mode-only" width="244px" alt="Stream Logo" style="max-width: 100%;"></a>

Pulse 很荣幸获得 [Stream](https://getstream.io/chat/sdk/swiftui/?utm_source=Github&utm_medium=github_repo_content_ad&utm_content=Developer&utm_campaign=Pulse_October2022_SwiftUI_klmh22) 的赞助。Stream 是企业级 Feed 与 Chat API 领域的领先提供商。

## 关于 Pulse

`Pulse` 不只是一个工具，更是一套框架。它可以记录来自 `URLSession` 的事件，或者来自依赖 `URLSession` 的框架（例如 [Alamofire](https://github.com/Alamofire/Alamofire) 与 [Get](https://github.com/kean/Get)）的事件，并通过你直接集成到 App 中的 `PulseUI` 视图进行展示。

这样一来，凡是拿到测试构建的人都能使用 Pulse 控制台。你或 QA 团队可以直接在设备上查看日志，并轻松导出后附加到 Bug 报告中。

> Pulse **不是** 像 Proxyman、Charles 或 Wireshark 那样的网络调试代理工具。它**不会**自动拦截来自 App 或设备的所有网络流量。

## 快速开始

开始使用 Pulse 的最佳入口是官方的 [**Getting Started**](https://kean-docs.github.io/pulse/documentation/pulse/gettingstarted) 指南。想了解更多用法，可以继续查看这些官方文档：

- [**Pulse Docs**](https://kean-docs.github.io/pulse/documentation/pulse/)：介绍主框架的集成方式与日志启用方法
- [**PulseUI Docs**](https://kean-docs.github.io/pulseui/documentation/pulseui/)：介绍如何把调试菜单与控制台集成到 App 中
- [**PulseLogHandler Docs**](https://kean-docs.github.io/pulseloghandler/documentation/pulseloghandler/)：介绍如何把 Pulse 作为 [SwiftLog](https://github.com/apple/swift-log) 后端使用

<a href="https://kean.blog/pulse/home">
<img src="https://user-images.githubusercontent.com/1567433/184552639-cf6765df-b5af-416b-95d3-0204e32df9d6.png">
</a>

## Pulse Pro

[**Pulse Pro**](https://kean.blog/pulse/pro) 是一款专业的开源 macOS 应用，可以让你实时查看日志。它强调灵活、可扩展和精确，同时遵循熟悉的 macOS 交互模式。面对大型日志文件时，它也能通过表格模式、文本模式、过滤器、滚动标记、全新网络检查器、JSON 过滤等能力提升排查效率。

Pulse 与 Pulse Pro 都是完全开源的。

## 最低要求

| Pulse      | Swift     | Xcode       | 平台                                             |
|------------|-----------|-------------|--------------------------------------------------|
| Pulse 2.0  | Swift 5.6 | Xcode 13.3  | iOS 13.0、watchOS 7.0、tvOS 13.0、macOS 11.0    |
| Pulse 1.0  | Swift 5.3 | Xcode 12.0  | iOS 11.0、watchOS 6.0、tvOS 11.0、macOS 11.0    |

## 许可证

Pulse 基于 MIT 许可证发布。详情见 LICENSE 文件。
