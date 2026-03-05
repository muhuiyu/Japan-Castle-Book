import JapanCastleBook
import SwiftUI

extension CastleArea {
    var displayName: String {
        switch self {
        case .hokkaidoTohoku:
            return L10n.areaHokkaidoTohoku
        case .kantoKoshinetsu:
            return L10n.areaKantoKoshinetsu
        case .hokurikuTokai:
            return L10n.areaHokurikuTokai
        case .kinki:
            return L10n.areaKinki
        case .chugokuShikoku:
            return L10n.areaChugokuShikoku
        case .kyusyuOkinawa:
            return L10n.areaKyushuOkinawa
        }
    }

    var sectionTint: Color {
        switch self {
        case .hokkaidoTohoku:
            return .cyan
        case .kantoKoshinetsu:
            return .yellow
        case .hokurikuTokai:
            return .pink
        case .kinki:
            return .mint
        case .chugokuShikoku:
            return .orange
        case .kyusyuOkinawa:
            return .brown
        }
    }
}
