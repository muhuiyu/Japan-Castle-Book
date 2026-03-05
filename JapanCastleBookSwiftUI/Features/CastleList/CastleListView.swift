import Algorithms
import Combine
import JapanCastleBook
import SwiftUI

struct CastleListView: View {
    private enum CastleSeries: String, CaseIterable {
        case top100
        case sequel100

        var title: String {
            switch self {
            case .top100:
                return L10n.castleSeriesTop100
            case .sequel100:
                return L10n.castleSeriesSequel100
            }
        }

        var idRange: ClosedRange<Int> {
            switch self {
            case .top100:
                return 1...100
            case .sequel100:
                return 101...200
            }
        }
    }

    @EnvironmentObject private var experienceStore: CastleExperienceStore
    @StateObject var viewModel: CastleListViewModel
    let stampAssetService: CastleStampAssetService
    @State private var route: CastleRoute?
    @State private var selectedSeries: CastleSeries = .top100

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    errorContent(message: errorMessage)
                } else {
                    listContent
                }
            }
            .navigationTitle(L10n.castleListTitle)
            .navigationDestination(item: $route) { route in
                CastleDetailView(castle: route.castle)
            }
        }
        .environment(\.castleStampAssetService, stampAssetService)
        .task {
            guard viewModel.castles.isEmpty else { return }
            viewModel.loadCastles()
        }
    }

    private var listContent: some View {
        List {
            Section {
                Picker("Castle Series", selection: $selectedSeries) {
                    ForEach(CastleSeries.allCases, id: \.self) { series in
                        Text(series.title).tag(series)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.castleListProgressTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(L10n.castleListVisitProgress(visitedCount, progressTotalCount))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }

            if filteredCastles.isEmpty {
                Section {
                    VStack(spacing: 8) {
                        Text(L10n.castleSeriesEmptyTitle)
                            .font(.headline)
                        Text(L10n.castleSeriesEmptyMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                }
            } else {
                ForEach(filteredSections) { section in
                    Section {
                        ForEach(section.rows.indices, id: \.self) { index in
                            CastleListCellRowView(castles: section.rows[index]) { castle in
                                route = CastleRoute(castle: castle)
                            }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                        }
                    } header: {
                        HStack {
                            Text(section.area.displayName)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(section.area.sectionTint.opacity(0.30))
                                .clipShape(Capsule())
                            Spacer()
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

    private var visitedCount: Int {
        filteredCastles.filter { experienceStore.hasVisited($0.id) }.count
    }

    private var progressTotalCount: Int {
        max(filteredCastles.count, 100)
    }

    private var filteredCastles: [Castle] {
        viewModel.castles.filter { selectedSeries.idRange.contains($0.id) }
    }

    private var filteredSections: [CastleListViewModel.Section] {
        viewModel.sections(for: filteredCastles)
    }

    private func errorContent(message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)

            Button(L10n.retry) {
                viewModel.loadCastles()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct CastleRoute: Identifiable, Hashable {
    let castle: Castle
    var id: CastleID { castle.id }

    static func == (lhs: CastleRoute, rhs: CastleRoute) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class CastleListViewModel: ObservableObject {
    struct Section: Identifiable {
        let area: CastleArea
        let rows: [[Castle]]

        var id: CastleArea { area }
    }

    @Published private(set) var castles: [Castle] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let castleService: CastleService
    private var cancellables = Set<AnyCancellable>()

    init(castleService: CastleService) {
        self.castleService = castleService
    }

    func loadCastles() {
        isLoading = true
        errorMessage = nil

        castleService.load()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                if case let .failure(error) = completion {
                    self.errorMessage = self.message(for: error)
                }
            } receiveValue: { [weak self] castles in
                self?.castles = castles
            }
            .store(in: &cancellables)
    }

    var orderedSections: [Section] {
        sections(for: castles)
    }

    func sections(for castles: [Castle]) -> [Section] {
        castles
            .grouped(by: \.area)
            .sorted { $0.key < $1.key }
            .map { area, castles in
                Section(area: area, rows: castles.chunks(ofCount: 3).map(Array.init))
            }
    }

    private func message(for error: CastleServiceError) -> String {
        switch error {
        case .missingFile:
            return L10n.errorMissingFile
        case .invalidData:
            return L10n.errorInvalidData
        case .connectivity:
            return L10n.errorConnectivity
        }
    }
}

private struct CastleListCellRowView: View {
    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castles: [Castle]
    let onTapCastle: (Castle) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(castles, id: \.id) { castle in
                Button {
                    onTapCastle(castle)
                } label: {
                    CastleListCellView(
                        castle: castle,
                        hasVisited: experienceStore.hasVisited(castle.id)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }

            if castles.count < 3 {
                ForEach(0..<(3 - castles.count), id: \.self) { _ in
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct CastleListCellView: View {
    @Environment(\.castleStampAssetService) private var stampAssetService

    let castle: Castle
    let hasVisited: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.tertiarySystemFill), lineWidth: 2)
                    )

                Image(AssetImage.castle)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.25)
                    .padding(14)

                if hasVisited {
                    Image(stampAssetService.stampAssetName(for: castle.id) ?? AssetImage.doneStamp)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .transition(.opacity)
                }
            }
            .frame(height: 84)

            Text("\(castle.id). \(castle.name)")
                .font(castle.name.count > 10 ? .caption2 : .caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CastleListView(
        viewModel: CastleListViewModel(castleService: CastleAppEnvironment.live.castleService),
        stampAssetService: CastleAppEnvironment.live.castleStampAssetService
    )
    .environmentObject(CastleExperienceStore())
}
