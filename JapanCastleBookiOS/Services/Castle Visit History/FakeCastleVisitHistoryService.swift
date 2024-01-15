//
//  FakeCastleVisitHistoryService.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/15/24.
//

import Foundation
import JapanCastleBook

class FakeCastleVisitHistoryService: CastleVisitHistoryStoreService {
    func hasVisitedCastle(for castleID: Int) -> Bool {
        return false
    }
    
    func retrieve() -> RetrievalResult {
        fatalError("Not implemented")
    }
    
    func insert(_ visitHistory: JapanCastleBook.CastleVisitHistory) -> InsertionResult {
        fatalError("Not implemented")
    }
    
    func delete(at visitHistoryID: UUID) -> DeletionResult {
        fatalError("Not implemented")
    }
}
