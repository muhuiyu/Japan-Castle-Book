import Algorithms
import Combine
import Foundation
import JapanCastleBook

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
