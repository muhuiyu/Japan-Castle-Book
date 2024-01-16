//
//  CastleVisitHistoryStore.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/16/24.
//

import Foundation
import Combine

public protocol CastleVisitHistoryStore {
    func deleteVisitHistory() -> AnyPublisher<Void, Error>
    func insert(_ historyList: [CastleVisitHistory]) -> AnyPublisher<Void, Error>
    func retrieve() -> AnyPublisher<[CastleVisitHistory], Error>
}
