//
//  Castle.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation

public struct Castle: Equatable {
    public let id: Int
    public let name: String
    public let reading: String
    public let area: CastleArea
    public let address: String
    public let phoneNumber: String
    public let openingHours: String
    public let accessGuide: String
    public let parkingInfo: String
    public let stampLocation: String
    public let overview: String
    public let imageURLs: [URL]
    
    public init(
        id: Int,
        name: String,
        reading: String,
        area: CastleArea,
        address: String,
        phoneNumber: String,
        openingHours: String,
        accessGuide: String,
        parkingInfo: String,
        stampLocation: String,
        overview: String,
        imageURLs: [URL]
    ) {
        self.id = id
        self.name = name
        self.reading = reading
        self.area = area
        self.address = address
        self.phoneNumber = phoneNumber
        self.openingHours = openingHours
        self.accessGuide = accessGuide
        self.parkingInfo = parkingInfo
        self.stampLocation = stampLocation
        self.overview = overview
        self.imageURLs = imageURLs
    }
}

public enum CastleArea: Int, CaseIterable, Comparable {
    case hokkaidoTohoku = 0
    case kantoKoshinetsu
    case hokurikuTokai
    case kinki
    case chugokuShikoku
    case kyusyuOkinawa
    
    public static func < (lhs: CastleArea, rhs: CastleArea) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
