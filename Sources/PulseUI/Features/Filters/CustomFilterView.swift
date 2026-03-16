// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

#if os(iOS) || os(macOS)

@available(iOS 14.0, *)
struct CustomFilterView: View {
    @ObservedObject var filter: ConsoleSearchFilter
    let onRemove: () -> Void

    #if os(iOS)

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                fieldMenu
                Spacer().frame(width: 8)
                matchMenu
                Spacer(minLength: 0)
                Button(action: onRemove) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
            TextField(L10n.tr("pulse.filters.value"), text: $filter.value)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 4))
        .cornerRadius(8)
    }

    // TODO: On iOS 16, inline picker looks OK
    private var fieldMenu: some View {
        Menu(content: {
            fieldPicker
        }, label: {
            FilterPickerButton(title: filter.field.localizedTitle)
        }).animation(.none)
    }

    private var matchMenu: some View {
        Menu(content: {
            matchPicker
        }, label: {
            FilterPickerButton(title: filter.match.localizedTitle)
        }).animation(.none)
    }

    #else

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                fieldPicker
                    .frame(width: 140)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
            HStack {
                matchPicker
                    .frame(width: 140)
                Spacer()
            }
            HStack {
                TextField(L10n.tr("pulse.filters.value"), text: $filter.value)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    #endif

    private var fieldPicker: some View {
        Picker(L10n.tr("pulse.filters.field"), selection: $filter.field) {
            Text(L10n.tr("pulse.message.level")).tag(ConsoleSearchFilter.Field.level)
            Text(L10n.tr("pulse.message.label")).tag(ConsoleSearchFilter.Field.label)
            Text(L10n.tr("pulse.filters.message")).tag(ConsoleSearchFilter.Field.message)
            Divider()
            Text(L10n.tr("pulse.message.metadata")).tag(ConsoleSearchFilter.Field.metadata)
            Divider()
            Text(L10n.tr("pulse.message.file")).tag(ConsoleSearchFilter.Field.file)
        }
        .labelsHidden()
    }

    private var matchPicker: some View {
        Picker(L10n.tr("pulse.filters.match"), selection: $filter.match) {
            Text(L10n.tr("pulse.filters.contains")).tag(ConsoleSearchFilter.Match.contains)
            Text(L10n.tr("pulse.filters.not_contains")).tag(ConsoleSearchFilter.Match.notContains)
            Divider()
            Text(L10n.tr("pulse.filters.equals")).tag(ConsoleSearchFilter.Match.equal)
            Text(L10n.tr("pulse.filters.not_equals")).tag(ConsoleSearchFilter.Match.notEqual)
            Divider()
            Text(L10n.tr("pulse.filters.begins_with")).tag(ConsoleSearchFilter.Match.beginsWith)
            Divider()
            Text(L10n.tr("pulse.search.regex")).tag(ConsoleSearchFilter.Match.regex)
        }
        .labelsHidden()
    }
}

#endif
