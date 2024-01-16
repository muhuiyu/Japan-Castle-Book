//
//  CastleVisitHistoryService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import Combine

public protocol CastleVisitHistoryService {
    typealias RetrievalResult = AnyPublisher<[CastleVisitHistory], Error>
    typealias InsertionResult = AnyPublisher<Void, Error>
    typealias DeletionResult = AnyPublisher<Void, Error>
    
    func hasVisitedCastle(for castleID: Int) -> Bool
    func retrieve() -> RetrievalResult
    func insert(_ visitHistory: CastleVisitHistory) -> InsertionResult
    func delete(at visitHistoryID: UUID) -> DeletionResult
}
