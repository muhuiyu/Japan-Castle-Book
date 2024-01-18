//
//  ManagedCastleVisitHistory.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import CoreData

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
    
    static func find(in context: NSManagedObjectContext) throws -> [ManagedCastleVisitHistory] {
        let request = NSFetchRequest<ManagedCastleVisitHistory>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
}
