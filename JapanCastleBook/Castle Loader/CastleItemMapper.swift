//
//  CastleItemMapper.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation

public final class CastleItemMapper {
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private struct RemoteCastleItem: Decodable {
        let id: RemoteCastleItemID
        let name: String
        let reading: String
        let areaCode: Int
        let address: String
        let phoneNumber: String
        let openingHours: String
        let accessGuide: String
        let parkingInfo: String
        let stampLocation: String
        let overview: String
        let imageURLs: [URL]
        
        struct RemoteCastleItemID: Decodable {
            let value: Int
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case reading
            case areaCode = "area"
            case address
            case phoneNumber = "phone_number"
            case openingHours = "opening_hours"
            case accessGuide = "access_guide"
            case parkingInfo = "parking_info"
            case stampLocation = "stamp_location"
            case overview
            case imageURLs = "image_urls"
        }
        
        var castle: Castle {
            Castle(
                id: id.value,
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
        }
        
        var area: CastleArea {
            return switch areaCode {
            case 0: CastleArea.hokkaidoTohoku
            case 1: CastleArea.kantoKoshinetsu
            case 2: CastleArea.hokurikuTokai
            case 3: CastleArea.kinki
            case 4: CastleArea.chugokuShikoku
            case 5: CastleArea.kyusyuOkinawa
            default: CastleArea.hokkaidoTohoku
            }
        }
    }
    
    public static func map(_ data: Data) throws -> [Castle] {
        guard let castles = try? JSONDecoder().decode([RemoteCastleItem].self, from: data) else {
            throw Error.invalidData
        }
        return castles.map { $0.castle }
    }
}
