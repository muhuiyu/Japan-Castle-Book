import Foundation
import JapanCastleBook
import SwiftUI

protocol CastleStampAssetService {
    func stampAssetName(for castleID: CastleID) -> String?
}

struct LocalCastleStampAssetService: CastleStampAssetService {
    private let assetsByID: [CastleID: String]

    init(assetNames: [String] = AssetImage.stampAssetNames) {
        var map: [CastleID: String] = [:]

        for name in assetNames {
            guard
                name.hasPrefix(AssetImage.stampPrefix),
                let idPart = name.split(separator: "-").dropFirst().first,
                let castleID = Int(idPart)
            else {
                continue
            }

            map[castleID] = name
        }

        self.assetsByID = map
    }

    func stampAssetName(for castleID: CastleID) -> String? {
        assetsByID[castleID]
    }
}

private struct CastleStampAssetServiceKey: EnvironmentKey {
    static let defaultValue: CastleStampAssetService = LocalCastleStampAssetService()
}

extension EnvironmentValues {
    var castleStampAssetService: CastleStampAssetService {
        get { self[CastleStampAssetServiceKey.self] }
        set { self[CastleStampAssetServiceKey.self] = newValue }
    }
}
