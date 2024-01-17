//
//  ManagedCastleVisitHistory.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import CoreData
import JapanCastleBook

@objc(ManagedCastleVisitHistory)
final class ManagedCastleVisitHistory: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var title: String
    @NSManaged var content: String?
}

extension ManagedCastleVisitHistory {
    var model: CastleVisitHistory {
        CastleVisitHistory(id: id, date: date, title: title, content: content, photoURLs: [])
    }
}
