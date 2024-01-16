//
//  XCTest+CastleVisitHistoryStoreHelpers.swift
//  JapanCastleBookTests
//
//  Created by Mu Yu on 1/11/24.
//

import XCTest
import Combine
import JapanCastleBook

extension XCTestCase {
    func expect(_ sut: CastleVisitHistoryService, toRetrieve expectedHistories: [CastleVisitHistory]?, withError expectedError: Error?, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        var retrievedHistories: [CastleVisitHistory]?
        var retrievedError: Error?
        let _ = sut.retrieve()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    retrievedError = error
                default: break
                }
                exp.fulfill()
            }, receiveValue: { visitHistories in
                retrievedHistories = visitHistories
            })

        wait(for: [exp], timeout: 1.0)

        if let retrievedHistories, let expectedHistories {
            XCTAssertEqual(retrievedHistories, expectedHistories, "Expected \(expectedHistories) but got \(retrievedHistories)", file: file, line: line)
        } else if let expectedError = expectedError as? NSError, let retrievedError = retrievedError as? NSError {
            XCTAssertEqual(retrievedError, expectedError, "Expected \(expectedError) but got \(retrievedError)", file: file, line: line)
        } else {
            XCTFail("Expected result or error but got neither", file: file, line: line)
        }
    }
}
