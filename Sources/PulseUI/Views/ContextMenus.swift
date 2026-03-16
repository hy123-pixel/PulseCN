// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse
import Combine

#if os(iOS) || os(macOS)

struct ButtonCopyMessage: View {
    let text: String

    var body: some View {
        Button(action: {
            UXPasteboard.general.string = text
            runHapticFeedback()
        }) {
            Text(L10n.tr("pulse.context.copy_message"))
            Image(systemName: "doc.on.doc")
        }
    }
}

struct NetworkMessageContextMenu: View {
    let task: NetworkTaskEntity

    @Binding private(set) var sharedItems: ShareItems?

    var body: some View {
        Section {
            if #available(iOS 14.0, *) {
                Menu(L10n.tr("pulse.context.share_request_log")) {
                    shareAsButtons
                }
            } else {
                shareAsButtons
            }
            if task.responseBodySize > 0 {
                Button(action: {
                    sharedItems = ShareItems([task.responseBody?.data ?? Data()])
                }) {
                    Text(L10n.tr("pulse.context.share_response"))
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        NetworkMessageContextMenuCopySection(task: task)
        if let message = task.message {
            PinButton(viewModel: .init(message: message))
        }
    }

    @ViewBuilder
    private var shareAsButtons: some View {
        Button(action: {
            sharedItems = ShareItems([ConsoleShareService.share(task, output: .plainText)])
        }) {
            Text(L10n.tr("pulse.context.share_plain_text"))
            Image(systemName: "square.and.arrow.up")
        }
        Button(action: {
            let text = ConsoleShareService.share(task, output: .markdown)
            let directory = TemporaryDirectory()
            let fileURL = directory.write(text: text, extension: "markdown")
            sharedItems = ShareItems([fileURL], cleanup: directory.remove)
        }) {
            Text(L10n.tr("pulse.context.share_markdown"))
            Image(systemName: "square.and.arrow.up")
        }
        Button(action: {
            let text = ConsoleShareService.share(task, output: .html)
            let directory = TemporaryDirectory()
            let fileURL = directory.write(text: text, extension: "html")
            sharedItems = ShareItems([fileURL], cleanup: directory.remove)
        }) {
            Text(L10n.tr("pulse.context.share_html"))
            Image(systemName: "square.and.arrow.up")
        }
        Button(action: {
            sharedItems = ShareItems([task.cURLDescription()])
        }) {
            Text(L10n.tr("pulse.network.share_as_curl"))
            Image(systemName: "square.and.arrow.up")
        }
    }
}

struct NetworkMessageContextMenuCopySection: View {
    var task: NetworkTaskEntity

    var body: some View {
        Section {
            if let url = task.url {
                Button(action: {
                    UXPasteboard.general.string = url
                    runHapticFeedback()
                }) {
                    Text(L10n.tr("pulse.context.copy_url"))
                    Image(systemName: "doc.on.doc")
                }
            }
            if let host = task.host?.value {
                Button(action: {
                    UXPasteboard.general.string = host
                    runHapticFeedback()
                }) {
                    Text(L10n.tr("pulse.context.copy_host"))
                    Image(systemName: "doc.on.doc")
                }
            }
            if task.responseBodySize > 0 {
                Button(action: {
                    guard let data = task.responseBody?.data else { return }
                    UXPasteboard.general.string = String(data: data, encoding: .utf8)
                    runHapticFeedback()
                }) {
                    Text(L10n.tr("pulse.context.copy_response"))
                    Image(systemName: "doc.on.doc")
                }
            }
        }
    }
}
#endif

#if os(iOS) || os(macOS)
@available(iOS 14.0, *)
struct StringSearchOptionsMenu: View {
    @Binding private(set) var options: StringSearchOptions
    var isKindNeeded = true

    #if os(macOS)
    var body: some View {
        Menu(content: {
            pickerCase
            pickerKind
            pickerOptions
        }, label: {
            Image(systemName: "ellipsis.circle")
        })
        .menuStyle(BorderlessButtonMenuStyle(showsMenuIndicator: false))
    }
    #else
    var body: some View {
        pickerCase
        pickerKind
        pickerOptions
    }
    #endif

    var pickerCase: some View {
        Picker(options.isCaseSensitive ? L10n.tr("pulse.search.case_sensitive") :  L10n.tr("pulse.search.case_insensitive"), selection: $options.isCaseSensitive) {
            Text(L10n.tr("pulse.search.case_sensitive")).tag(true)
            Text(L10n.tr("pulse.search.case_insensitive")).tag(false)
        }.pickerStyle(.inline)
    }

    var pickerKind: some View {
        Picker(options.isRegex ? L10n.tr("pulse.search.regex") : L10n.tr("pulse.search.text"), selection: $options.isRegex) {
            Text(L10n.tr("pulse.search.text")).tag(false)
            Text(L10n.tr("pulse.search.regex")).tag(true)
        }.pickerStyle(.inline)
    }

    @ViewBuilder
    var pickerOptions: some View {
        if !options.isRegex && isKindNeeded {
            Picker(options.kind.rawValue, selection: $options.kind) {
                ForEach(StringSearchOptions.Kind.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }.pickerStyle(.inline)
        }
    }
}
#endif
