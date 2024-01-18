//
//  LocalCastleVisitHistoryService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/16/24.
//

import Foundation

class LocalCastleVisitHistoryService: CastleVisitHistoryService {
    
    private let store: CastleVisitHistoryStore
    
    init(store: CastleVisitHistoryStore) {
        self.store = store
    }
}

extension LocalCastleVisitHistoryService {
    
    func hasVisitedCastle(for castleID: Int) -> Bool {
        fatalError("Not implemented")
    }
}

extension LocalCastleVisitHistoryService {
    
    func retrieve() -> RetrievalResult {
        return store.retrieve()
    }
    
}

extension LocalCastleVisitHistoryService {
    
    func insert(_ visitHistoryList: [CastleVisitHistory]) -> InsertionResult {
        return store.insert(visitHistoryList)
    }
    
}

extension LocalCastleVisitHistoryService {
    
    func delete(at visitHistoryID: UUID) -> DeletionResult {
        return store.delete(visitHistoryID)
    }
    
}
