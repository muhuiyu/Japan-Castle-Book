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
    
    func test_retrieve_deliversCachedCastleVisitHistoryAfterInserting() {
        let sut = makeSUT()
        
        let item1 = makeItem(title: "any title", content: "any content", photoURLs: [])
        _ = sut.insert(item1)
        
        let item2 = makeItem(title: "another title", content: "another content", photoURLs: [URL(string: "https://any-url.com")!])
        _ = sut.insert(item2)
        
        expect(sut, toRetrieve: [item1, item2], withError: nil)
    }
    
    func test_retrieve_deliversUniqueCachedCastleVisitHistoryAfterInserting() {
        let sut = makeSUT()
        
        let item1 = makeItem(title: "any title", content: "any content", photoURLs: [])
        _ = sut.insert(item1)
        _ = sut.insert(item1)
        
        expect(sut, toRetrieve: [item1], withError: nil)
    }
}

extension CoreDataCastleVisitHistoryStoreTests {
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CastleVisitHistoryStore  {
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCastleVisitHistoryStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeItem(title: String, content: String, photoURLs: [URL]) -> CastleVisitHistory {
        return CastleVisitHistory(id: UUID(), date: Date(), title: title, content: content, photoURLs: photoURLs)
    }
}
