//
//  CastleItemMapperTests.swift
//  JapanCastleBookTests
//
//  Created by Mu Yu on 1/11/24.
//

import XCTest
import JapanCastleBook

final class CastleItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnInvalidJSONList() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try CastleItemMapper.map(invalidJSON)
        )
    }
    
    func test_map_deliversEmptyListOnEmptyJSONList() {
        let emptyListJSON = makeItemsJSON([])
        
        XCTAssertEqual(try CastleItemMapper.map(emptyListJSON), [])
    }
    
}

// MARK: - Helpers
extension CastleItemMapperTests {
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
}
