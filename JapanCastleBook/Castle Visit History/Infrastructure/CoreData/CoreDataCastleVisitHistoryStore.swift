//
//  CoreDataCastleVisitHistoryStore.swift
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
    
    public func insert(_ visitHistory: CastleVisitHistory) -> InsertionResult {
        do {
            let managedCastleHistory = try ManagedCastleVisitHistory.newUniqueInstance(in: context)
            managedCastleHistory.id = visitHistory.id
            managedCastleHistory.date = visitHistory.date
            managedCastleHistory.title = visitHistory.title
            managedCastleHistory.content = visitHistory.content
            managedCastleHistory.photoURLs = visitHistory.photoURLs
            try context.save()

            return Future { $0(.success(())) }.eraseToAnyPublisher()
            
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    public func retrieve() -> RetrievalResult {
        return fetchCastleVisitHistory().eraseToAnyPublisher()
    }
    
    public func delete(_ visitHistoryID: UUID) -> DeletionResult {
        fatalError("Not implemented")
    }
    
    public func deleteAllVisitHistories() -> DeletionResult {
        do {
            try ManagedCastleVisitHistory.deleteCache(in: context)
            return Future { $0(.success(())) }.eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

extension CoreDataCastleVisitHistoryStore {
    private func fetchCastleVisitHistory() -> Future<[CastleVisitHistory], Error> {
        return Future { [context] promise in
            context.perform {
                do {
                    let result = try ManagedCastleVisitHistory.find(in: context).map { $0.model }
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }

}
