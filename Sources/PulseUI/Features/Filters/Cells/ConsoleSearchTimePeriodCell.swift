// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(macOS) || os(visionOS)

import SwiftUI
import Pulse

struct ConsoleSearchTimePeriodCell: View {
    @Binding var selection: ConsoleFilters.Dates

    var body: some View {
        DateRangePicker(title: L10n.tr("pulse.date.start"), date: $selection.startDate)
        DateRangePicker(title: L10n.tr("pulse.date.end"), date: $selection.endDate)
        quickFilters
    }

    @ViewBuilder
    private var quickFilters: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(L10n.tr("pulse.filters.quick_filters"))
                .lineLimit(1)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(L10n.tr("pulse.filters.recent")) { selection = .recent }
            Button(L10n.tr("pulse.filters.today")) { selection = .today }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .foregroundColor(.accentColor)
    }
}

#endif
