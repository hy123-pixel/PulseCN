// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import CoreData
import Pulse
import Combine

#if os(iOS)

public struct PinsView: View {
    @ObservedObject var viewModel: PinsViewModel
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    public init(store: LoggerStore = .shared) {
        self.viewModel = PinsViewModel(store: store)
    }

    init(viewModel: PinsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        contents
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(Text(L10n.tr("pulse.main.pins")))
            .navigationBarItems(leading: navigationBarLeadingItems, trailing: navigationBarTralingItems)
            .onAppear { viewModel.onAppear() }
            .onAppear { viewModel.onDisappear() }
    }

    private var navigationBarLeadingItems: some View {
        viewModel.onDismiss.map {
            Button(action: $0) {
                Image(systemName: "xmark")
            }
        }
    }

    private var navigationBarTralingItems: some View {
        Button(action: viewModel.removeAllPins) {
            Image(systemName: "trash")
        }.disabled(viewModel.messages.isEmpty)
    }

    @ViewBuilder
    private var contents: some View {
        if viewModel.messages.isEmpty {
            placeholder
                .navigationBarTitle(Text(L10n.tr("pulse.main.pins")))
        } else {
            ConsoleTableView(
                header: { EmptyView() },
                viewModel: viewModel.table,
                detailsViewModel: viewModel.details
            )
        }
    }

    private var placeholder: PlaceholderView {
        PlaceholderView(imageName: "pin.circle", title: L10n.tr("pulse.pins.no_pins"), subtitle: L10n.tr("pulse.pins.hint"))
    }
}

#if DEBUG
struct PinsView_Previews: PreviewProvider {
    static var previews: some View {
        PinsView(viewModel: .init(store: .mock))
    }
}
#endif

#endif
