//
//  CoreDataCastleVisitHistoryStoreTests.swift
//  JapanCastleBookTests
//
//  Created by Mu Yu on 1/11/24.
//

import XCTest
import JapanCastleBook

final class CoreDataCastleVisitHistoryStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
}

extension CoreDataCastleVisitHistoryStoreTests {
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CastleVisitHistoryStore  {
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCastleVisitHistoryStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
