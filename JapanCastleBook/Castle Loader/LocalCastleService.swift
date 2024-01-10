//
//  LocalCastleService.swift
//  JapanCastleBook
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import Combine

public final class LocalCastleService: CastleService {
    private let jsonFileName = "castles"
    
    public init() {}
    
    public func load() -> AnyPublisher<[Castle], CastleServiceError> {
        return Future<[Castle], CastleServiceError> { promise in
            guard
                let url = Bundle(for: type(of: self)).url(forResource: self.jsonFileName, withExtension: "json") else {
                promise(.failure(.missingFile))
                return
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let items = try? CastleItemMapper.map(data)
            else {
                promise(.failure(.invalidData))
                return
            }
            
            promise(.success(items))
        }
        .eraseToAnyPublisher()
    }
}
