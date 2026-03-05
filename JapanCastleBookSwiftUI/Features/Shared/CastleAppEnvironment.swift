import Foundation
import JapanCastleBook

struct CastleAppEnvironment {
    let castleService: CastleService

    static let live = CastleAppEnvironment(castleService: LocalCastleService())
}
