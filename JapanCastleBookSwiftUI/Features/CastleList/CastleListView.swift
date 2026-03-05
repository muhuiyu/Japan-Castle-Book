import SwiftUI
import JapanCastleBook

struct CastleListView: View {
    // Keep sequel data hidden until content QA/enrichment is complete.
    private let sequelSeriesEnabled = false

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
        if selectedSeries == .sequel100 && !sequelSeriesEnabled {
            return []
        }
        return viewModel.castles.filter { selectedSeries.idRange.contains($0.id) }
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

#Preview {
    CastleListView(
        viewModel: CastleListViewModel(castleService: CastleAppEnvironment.live.castleService),
        stampAssetService: CastleAppEnvironment.live.castleStampAssetService
    )
    .environmentObject(CastleExperienceStore())
}
