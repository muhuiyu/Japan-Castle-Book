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
    
    func test_map_deliversItemsWithJSONItems() {
        let item1 = makeItem(id: 1, name: "name 1", address: "address 1", overview: "overview 1", imageURLs: [URL(string: "http://url-1.com")!])
        let item2 = makeItem(id: 2, name: "name 2", address: "address 2", overview: "overview 2", imageURLs: [URL(string: "http://url-2.com")!])
        let json = makeItemsJSON([item1.json, item2.json])
        
        XCTAssertEqual(try CastleItemMapper.map(json), [item1.model, item2.model])
    }
}

// MARK: - Helpers
extension CastleItemMapperTests {
    private func makeItem(
        id: Int = 0,
        name: String = "any name",
        reading: String = "any reading",
        address: String = "any address",
        phoneNumber: String = "12345678",
        openingHours: String = "any opening hours",
        accessGuide: String = "any access guide",
        parkingInfo: String = "any parking info",
        stampLocation: String = "any stamp location",
        area: CastleArea = .hokkaidoTohoku,
        overview: String = "any overview",
        imageURLs: [URL] = [URL(string: "any image")!]
    ) -> (model: Castle, json: [String: Any]) {
        let model = Castle(
            id: id,
            name: name,
            reading: reading,
            area: area,
            address: address,
            phoneNumber: phoneNumber,
            openingHours: openingHours,
            accessGuide: accessGuide,
            parkingInfo: parkingInfo,
            stampLocation: stampLocation,
            overview: overview,
            imageURLs: imageURLs
        )
        let json = [
            "id": [
                "value": id
            ],
            "name": name,
            "reading": reading,
            "area": area.rawValue,
            "address": address,
            "phone_number": phoneNumber,
            "opening_hours": openingHours,
            "access_guide": accessGuide,
            "parking_info": parkingInfo,
            "stamp_location": stampLocation,
            "overview": overview,
            "image_urls": imageURLs.map { $0.absoluteString }
        ].compactMapValues { $0 }
        
        return (model, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
}
