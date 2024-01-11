//
//  CastleVisitHistory.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation

public struct CastleVisitHistory {
    public let id: UUID
    public var date: Date
    public let title: String
    public let content: String?
    public let photoURLs: [URL]
    
    public init(id: UUID, date: Date, title: String, content: String?, photoURLs: [URL]) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.photoURLs = photoURLs
    }
}
