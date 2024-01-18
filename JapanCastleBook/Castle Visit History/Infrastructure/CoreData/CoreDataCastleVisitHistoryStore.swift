//
//  CoreDataCastleVisitHistoryService.swift
//  JapanCastleBookiOS
//
//  Created by Mu Yu on 1/11/24.
//

import Foundation
import CoreData
import Combine

public class CoreDataCastleVisitHistoryStore: CastleVisitHistoryStore {
    
    private static let modelName = "CastleVisitHistoryStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataCastleVisitHistoryStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataCastleVisitHistoryStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataCastleVisitHistoryStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    public func insert(_ visitHistoryList: [CastleVisitHistory]) -> InsertionResult {
        fatalError("Not implemented")
    }
    
    public func retrieve() -> RetrievalResult {
        return fetchCastleVisitHistory().eraseToAnyPublisher()
    }
    
    public func delete(_ visitHistoryID: UUID) -> DeletionResult {
        fatalError("Not implemented")
    }
    
    public func deleteAllVisitHistories() -> DeletionResult {
        fatalError("Not implemented")
    }
}

extension CoreDataCastleVisitHistoryStore {
    private func fetchCastleVisitHistory() -> Future<[CastleVisitHistory], Error> {
        let context = self.context
        
        return Future { promise in
            context.perform {
                do {
                    if let result = try ManagedCastleVisitHistory.find(in: context) {
                        let results = result.compactMap { $0.model }
                        promise(.success(results))
                    } else {
                        // Handle the case where no results are found
                        promise(.success([]))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }

}
