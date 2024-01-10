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
    
}
