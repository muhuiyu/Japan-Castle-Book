import Foundation
import JapanCastleBook

struct CastleAppEnvironment {
    let castleService: CastleService
    let castleStampAssetService: CastleStampAssetService

    static let live = CastleAppEnvironment(
        castleService: LocalCastleService(),
        castleStampAssetService: LocalCastleStampAssetService()
    )
}
