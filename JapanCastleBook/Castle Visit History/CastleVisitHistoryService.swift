//
//  CastleVisitHistoryService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation

public protocol CastleVisitHistoryService {
    func hasVisitedCastle(_ castleID: Int) -> Bool
}
