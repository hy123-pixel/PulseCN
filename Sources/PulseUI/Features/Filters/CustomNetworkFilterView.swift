// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

#if os(iOS) || os(macOS)

@available(iOS 14.0, *)
struct CustomNetworkFilterView: View {
    @ObservedObject var filter: NetworkSearchFilter
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
                .foregroundColor(Color.red)
            }
            TextField(L10n.tr("pulse.filters.value"), text: $filter.value)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 4))
        .cornerRadius(8)
    }
    
    private var fieldMenu: some View {
        Menu(content: {
            Picker("", selection: $filter.field) {
                fieldPickerBasicSection
                Divider()
                fieldPickerAdvancedSection
            }
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
                fieldPicker.frame(width: 140)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.plain)
                .foregroundColor(Color.red)
            }
            HStack {
                matchPicker.frame(width: 140)
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

    @ViewBuilder
    private var fieldPicker: some View {
        Picker(L10n.tr("pulse.filters.field"), selection: $filter.field) {
            fieldPickerBasicSection
            Divider()
            fieldPickerAdvancedSection
        }.labelsHidden()
    }

    @ViewBuilder
    private var fieldPickerBasicSection: some View {
        Text(L10n.tr("pulse.details.url")).tag(NetworkSearchFilter.Field.url)
        Text(L10n.tr("pulse.details.host")).tag(NetworkSearchFilter.Field.host)
        Text(L10n.tr("pulse.network.method")).tag(NetworkSearchFilter.Field.method)
        Text(L10n.tr("pulse.network.status_code")).tag(NetworkSearchFilter.Field.statusCode)
        Text(L10n.tr("pulse.network.error_code")).tag(NetworkSearchFilter.Field.errorCode)
    }

    @ViewBuilder
    private var fieldPickerAdvancedSection: some View {
        Text(L10n.tr("pulse.network.request_headers")).tag(NetworkSearchFilter.Field.requestHeader)
        Text(L10n.tr("pulse.network.response_headers")).tag(NetworkSearchFilter.Field.responseHeader)
        Divider()
        Text(L10n.tr("pulse.network.request_body")).tag(NetworkSearchFilter.Field.requestBody)
        Text(L10n.tr("pulse.network.response_body")).tag(NetworkSearchFilter.Field.responseBody)
    }

    private var matchPicker: some View {
        Picker(L10n.tr("pulse.filters.match"), selection: $filter.match) {
            Text(L10n.tr("pulse.filters.contains")).tag(NetworkSearchFilter.Match.contains)
            Text(L10n.tr("pulse.filters.not_contains")).tag(NetworkSearchFilter.Match.notContains)
            Divider()
            Text(L10n.tr("pulse.filters.equals")).tag(NetworkSearchFilter.Match.equal)
            Text(L10n.tr("pulse.filters.not_equals")).tag(NetworkSearchFilter.Match.notEqual)
            Divider()
            Text(L10n.tr("pulse.filters.begins_with")).tag(NetworkSearchFilter.Match.beginsWith)
            Divider()
            Text(L10n.tr("pulse.search.regex")).tag(NetworkSearchFilter.Match.regex)
        }.labelsHidden()
    }
}

#endif
