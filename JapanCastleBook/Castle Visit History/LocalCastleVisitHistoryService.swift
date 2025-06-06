//
//  LocalCastleVisitHistoryService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/16/24.
//

import Foundation

public class LocalCastleVisitHistoryService: CastleVisitHistoryService {
    
    private let store: CastleVisitHistoryStore
    
    public init(store: CastleVisitHistoryStore) {
        self.store = store
    }
}

extension LocalCastleVisitHistoryService {
    
    public func hasVisitedCastle(for castleID: Int) -> Bool {
        return [true, false].randomElement() ?? true
    }
}

extension LocalCastleVisitHistoryService {
    
    public func retrieve() -> RetrievalResult {
        return store.retrieve()
    }
    
}

extension LocalCastleVisitHistoryService {
    
    public func insert(_ visitHistoryList: CastleVisitHistory) -> InsertionResult {
        return store.insert(visitHistoryList)
    }
    
}

extension LocalCastleVisitHistoryService {
    
    public func delete(at visitHistoryID: UUID) -> DeletionResult {
        return store.delete(visitHistoryID)
    }
    
}
