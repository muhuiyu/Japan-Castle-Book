//
//  CastleListCellViewModel.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import JapanCastleBook

class CastleListCellViewModel {
    private let castle: Castle
    private let visitHistoryService: CastleVisitHistoryService
    
    init(castle: Castle, visitHistoryService: CastleVisitHistoryService) {
        self.castle = castle
        self.visitHistoryService = visitHistoryService
    }
    
    var title: String {
        return "\(castle.id). \(castle.name)"
    }
    
    var didTapCell: (() -> Void)?
    
    func hasVisited() -> Bool {
        return visitHistoryService.hasVisitedCastle(castle.id)
    }
}
