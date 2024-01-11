//
//  CastleListViewModel.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import Combine
import JapanCastleBook

class CastleListViewModel: BaseViewModel {
    
    let didTapCastle: ((Castle) -> Void)

    @Published private(set) var castles: [Castle] = []
    @Published private(set) var errorMessage: String?
    
    private let castleService: CastleService
    private let visitHistoryService: CastleVisitHistoryService
    
    init(
        coordinator: Coordinator? = nil,
        castleService: CastleService,
        visitHistoryService: CastleVisitHistoryService,
        didTapCastle: @escaping ((Castle) -> Void)
    ) {
        self.castleService = castleService
        self.visitHistoryService = visitHistoryService
        self.didTapCastle = didTapCastle
        super.init(coordinator: coordinator)
    }
}

extension CastleListViewModel {
    func loadCastles() {
        castleService.load()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.configureErrorMessage(for: error)
                }
            } receiveValue: { [weak self] items in
                self?.castles = items
            }
            .store(in: &subscriptions)
    }
    
    func title(at section: Int) -> String {
        CastleArea.allCases.map({ $0.title })[section]
    }
    
    private func configureErrorMessage(for error: CastleServiceError) {
        switch error {
        case .missingFile:
            errorMessage = "Missing file"
        case .invalidData:
            errorMessage = "Invalid data"
        case .connectivity:
            errorMessage = "Cannot connect to server"
        }
    }
}
