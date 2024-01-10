//
//  CastleService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Combine

public protocol CastleService {
    func load() -> AnyPublisher<[Castle], CastleServiceError>
}

public enum CastleServiceError: Swift.Error {
    case missingFile
    case invalidData
    case connectivity
}

