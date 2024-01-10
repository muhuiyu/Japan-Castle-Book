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
