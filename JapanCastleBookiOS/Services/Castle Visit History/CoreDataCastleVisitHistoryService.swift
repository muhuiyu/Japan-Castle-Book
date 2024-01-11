//
//  CoreDataCastleVisitHistoryService.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import CoreData
import JapanCastleBook
import Combine

class CoreDataCastleVisitHistoryService: CastleVisitHistoryStoreService {
    
    func hasVisitedCastle(for castleID: Int) -> Bool {
        fatalError("Not implemented")
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
