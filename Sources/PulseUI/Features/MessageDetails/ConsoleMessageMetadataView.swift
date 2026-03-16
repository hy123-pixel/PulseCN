// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

@available(iOS 16, macOS 13, visionOS 1, *)
struct ConsoleMessageMetadataView: View {
    let message: LoggerMessageEntity

    init(message: LoggerMessageEntity) {
        self.message = message
    }

    var body: some View {
        RichTextView(viewModel: .init(string: string))
            .navigationTitle(L10n.tr("pulse.message.details_title"))
    }

    private var string: NSAttributedString {
        let renderer = TextRenderer()
        let sections = KeyValueSectionViewModel.makeMetadata(for: message)
        renderer.render(sections)
        return renderer.make()
    }
}

extension KeyValueSectionViewModel {
    package static func makeMetadata(for message: LoggerMessageEntity) -> [KeyValueSectionViewModel] {
        let metadataItems: [(String, String?)] = message.metadata
            .sorted(by: { $0.key < $1.key })
            .map { ($0.key, $0.value )}
        return [
            KeyValueSectionViewModel(title: L10n.tr("pulse.message.summary"), color: .textColor(for: message.logLevel), items: [
                (L10n.tr("pulse.message.date"), DateFormatter.fullDateFormatter.string(from: message.createdAt)),
                (L10n.tr("pulse.message.level"), LoggerStore.Level(rawValue: message.level)?.name),
                (L10n.tr("pulse.message.label"), message.label.nonEmpty)
            ]),
            KeyValueSectionViewModel(title: L10n.tr("pulse.message.details"), color: .primary, items: [
                (L10n.tr("pulse.message.file"), message.file.nonEmpty),
                (L10n.tr("pulse.message.function"), message.function.nonEmpty),
                (L10n.tr("pulse.message.line"), message.line == 0 ? nil : "\(message.line)")
            ]),
            KeyValueSectionViewModel(title: L10n.tr("pulse.message.metadata"), color: .indigo, items: metadataItems)
        ]
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

#if DEBUG
@available(iOS 16, macOS 13, visionOS 1, *)
struct ConsoleMessageMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleMessageMetadataView(message: makeMockMessage())
        }
    }
}
#endif
