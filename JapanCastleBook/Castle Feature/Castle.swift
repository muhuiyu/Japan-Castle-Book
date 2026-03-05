//
//  Castle.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation

public typealias CastleID = Int

public struct Castle: Equatable {
    public struct RelatedWebsite: Equatable {
        public let name: String
        public let url: URL

        public init(name: String, url: URL) {
            self.name = name
            self.url = url
        }
    }

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
    public let relatedWebsites: [RelatedWebsite]
    
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
        imageURLs: [URL],
        relatedWebsites: [RelatedWebsite] = []
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
        self.relatedWebsites = relatedWebsites
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
