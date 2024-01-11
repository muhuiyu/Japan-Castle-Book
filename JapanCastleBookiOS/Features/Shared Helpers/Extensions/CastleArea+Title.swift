//
//  CastleArea+Title.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import JapanCastleBook

extension CastleArea {
    var title: String {
        switch self {
        case .hokkaidoTohoku: Text.castleAreaTitleHokkaidoTohoku
        case .kantoKoshinetsu: Text.castleAreaTitleKantoKoshinetsu
        case .hokurikuTokai: Text.castleAreaTitleKantoHokurikuTokai
        case .kinki: Text.castleAreaTitleKantoKinki
        case .chugokuShikoku: Text.castleAreaTitleKantoChugokuShikoku
        case .kyusyuOkinawa: Text.castleAreaTitleKantoKyusyuOkinawa
        }
    }
}
