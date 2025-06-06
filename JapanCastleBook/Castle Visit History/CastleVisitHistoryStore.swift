//
//  CastleVisitHistoryStore.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/16/24.
//

import Foundation
import Combine

public protocol CastleVisitHistoryStore {
    typealias RetrievalResult = AnyPublisher<[CastleVisitHistory], Error>
    typealias InsertionResult = AnyPublisher<Void, Error>
    typealias DeletionResult = AnyPublisher<Void, Error>
    
    func insert(_ visitHistory: CastleVisitHistory) -> InsertionResult
    func retrieve() -> RetrievalResult
    func delete(_ visitHistoryID: UUID) -> DeletionResult
    func deleteAllVisitHistories() -> DeletionResult
}
