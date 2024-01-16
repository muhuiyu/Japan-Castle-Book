//
//  CastleVisitHistoryStoreTests.swift
//  JapanCastleBookTests
//
//  Created by Mu Yu on 1/11/24.
//

import XCTest
import JapanCastleBook

final class CastleVisitHistoryStoreTests: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: CastleVisitHistoryService, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: [], withError: nil, file: file, line: line)
    }
}
