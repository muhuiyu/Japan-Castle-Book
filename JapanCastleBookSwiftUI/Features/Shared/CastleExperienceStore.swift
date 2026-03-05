import JapanCastleBook
import SwiftData
import SwiftUI
import UIKit

struct CastleVisitLogEntry: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let content: String
    let photos: [UIImage]

    init(
        id: UUID = UUID(),
        date: Date,
        title: String,
        content: String,
        photos: [UIImage]
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.photos = photos
    }
}

@Model
final class PersistedCastleExperience {
    @Attribute(.unique) var castleID: Int
    var hasDigitalStamp: Bool
    var stampPhotoData: Data?
    @Relationship(deleteRule: .cascade, inverse: \PersistedVisitLog.experience)
    var visitLogs: [PersistedVisitLog]

    init(castleID: Int, hasDigitalStamp: Bool = false, stampPhotoData: Data? = nil) {
        self.castleID = castleID
        self.hasDigitalStamp = hasDigitalStamp
        self.stampPhotoData = stampPhotoData
        self.visitLogs = []
    }
}

@Model
final class PersistedVisitLog {
    var id: UUID
    var date: Date
    var title: String
    var content: String
    var photoData: Data?
    @Relationship(deleteRule: .cascade, inverse: \PersistedVisitLogPhoto.visitLog)
    var photos: [PersistedVisitLogPhoto]
    var experience: PersistedCastleExperience?

    init(id: UUID = UUID(), date: Date, title: String, content: String, photoData: Data? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.photoData = photoData
        self.photos = []
    }
}

@Model
final class PersistedVisitLogPhoto {
    var id: UUID
    var order: Int
    var imageData: Data
    var visitLog: PersistedVisitLog?

    init(id: UUID = UUID(), order: Int, imageData: Data) {
        self.id = id
        self.order = order
        self.imageData = imageData
    }
}

@MainActor
final class CastleExperienceStore: ObservableObject {
    struct CastleExperience {
        var hasDigitalStamp = false
        var stampPhoto: UIImage?
        var visitLogs: [CastleVisitLogEntry] = []
    }

    @Published private var storage: [CastleID: CastleExperience] = [:]

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    static func makeAppModelContainer() -> ModelContainer {
        makeContainer()
    }

    init(modelContainer: ModelContainer? = nil) {
        if let modelContainer {
            self.modelContainer = modelContainer
        } else {
            self.modelContainer = Self.makeContainer()
        }

        self.modelContext = self.modelContainer.mainContext
        reloadFromPersistence()
    }

    func hasVisited(_ castleID: CastleID) -> Bool {
        guard let experience = storage[castleID] else { return false }

        return experience.hasDigitalStamp ||
            experience.stampPhoto != nil ||
            !experience.visitLogs.isEmpty
    }

    func hasStamp(_ castleID: CastleID) -> Bool {
        guard let experience = storage[castleID] else { return false }
        return experience.hasDigitalStamp || experience.stampPhoto != nil
    }

    func stampPhoto(for castleID: CastleID) -> UIImage? {
        storage[castleID]?.stampPhoto
    }

    func visitLogs(for castleID: CastleID) -> [CastleVisitLogEntry] {
        storage[castleID]?.visitLogs.sorted(by: isVisitDateDescending) ?? []
    }

    func addDigitalStamp(for castleID: CastleID) {
        let experience = fetchOrCreateExperience(castleID: castleID)
        experience.hasDigitalStamp = true
        saveAndReload()
    }

    func setStampPhoto(for castleID: CastleID, image: UIImage) {
        let experience = fetchOrCreateExperience(castleID: castleID)
        experience.stampPhotoData = encodedImageData(from: image)
        experience.hasDigitalStamp = true
        saveAndReload()
    }

    func removeStamp(for castleID: CastleID) {
        guard let experience = fetchExperience(castleID: castleID) else { return }
        experience.hasDigitalStamp = false
        experience.stampPhotoData = nil
        saveAndReload()
    }

    func addVisitLog(
        for castleID: CastleID,
        date: Date,
        title: String,
        content: String,
        photos: [UIImage]
    ) {
        let experience = fetchOrCreateExperience(castleID: castleID)
        let log = PersistedVisitLog(
            date: date,
            title: title,
            content: content,
            photoData: nil
        )
        setPhotos(photos, on: log)
        log.experience = experience
        experience.visitLogs.append(log)
        saveAndReload()
    }

    func updateVisitLog(
        for castleID: CastleID,
        logID: UUID,
        date: Date,
        title: String,
        content: String,
        photos: [UIImage]
    ) {
        guard let experience = fetchExperience(castleID: castleID),
              let log = experience.visitLogs.first(where: { $0.id == logID }) else {
            return
        }

        log.date = date
        log.title = title
        log.content = content
        setPhotos(photos, on: log)
        saveAndReload()
    }

    func removeVisitLog(for castleID: CastleID, logID: UUID) {
        guard let experience = fetchExperience(castleID: castleID),
              let log = experience.visitLogs.first(where: { $0.id == logID }) else {
            return
        }

        modelContext.delete(log)
        experience.visitLogs.removeAll(where: { $0.id == logID })
        saveAndReload()
    }

    private func fetchExperience(castleID: CastleID) -> PersistedCastleExperience? {
        let descriptor = FetchDescriptor<PersistedCastleExperience>(
            predicate: #Predicate { $0.castleID == castleID }
        )

        return try? modelContext.fetch(descriptor).first
    }

    private func fetchOrCreateExperience(castleID: CastleID) -> PersistedCastleExperience {
        if let existing = fetchExperience(castleID: castleID) {
            return existing
        }

        let created = PersistedCastleExperience(castleID: castleID)
        modelContext.insert(created)
        return created
    }

    private func saveAndReload() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save castle experience data: \(error)")
        }

        reloadFromPersistence()
    }

    private func reloadFromPersistence() {
        let descriptor = FetchDescriptor<PersistedCastleExperience>()

        guard let persistedExperiences = try? modelContext.fetch(descriptor) else {
            storage = [:]
            return
        }

        storage = Dictionary(uniqueKeysWithValues: persistedExperiences.map { experience in
            let logs = experience.visitLogs
                .map {
                    CastleVisitLogEntry(
                        id: $0.id,
                        date: $0.date,
                        title: $0.title,
                        content: $0.content,
                        photos: decodedPhotos(from: $0)
                    )
                }
                .sorted(by: isVisitDateDescending)

            let model = CastleExperience(
                hasDigitalStamp: experience.hasDigitalStamp,
                stampPhoto: image(from: experience.stampPhotoData),
                visitLogs: logs
            )

            return (experience.castleID, model)
        })
    }

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([PersistedCastleExperience.self, PersistedVisitLog.self, PersistedVisitLogPhoto.self])

        do {
            let config = ModelConfiguration(schema: schema)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            assertionFailure("Failed to create persistent ModelContainer: \(error)")

            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                fatalError("Could not create fallback in-memory ModelContainer: \(error)")
            }
        }
    }

    private func encodedImageData(from image: UIImage?) -> Data? {
        guard let image else { return nil }

        if let jpegData = image.jpegData(compressionQuality: 0.85) {
            return jpegData
        }

        return image.pngData()
    }

    private func image(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }

    private func decodedPhotos(from log: PersistedVisitLog) -> [UIImage] {
        let structuredPhotos = log.photos
            .sorted(by: { $0.order < $1.order })
            .compactMap { image(from: $0.imageData) }

        if !structuredPhotos.isEmpty {
            return structuredPhotos
        }

        // Backward compatibility for older persisted logs with a single photo blob.
        if let legacy = image(from: log.photoData) {
            return [legacy]
        }

        return []
    }

    private func setPhotos(_ images: [UIImage], on log: PersistedVisitLog) {
        for photo in log.photos {
            modelContext.delete(photo)
        }
        log.photos.removeAll()

        let encodedPhotos = images.compactMap { encodedImageData(from: $0) }
        for (index, data) in encodedPhotos.enumerated() {
            let persistedPhoto = PersistedVisitLogPhoto(order: index, imageData: data)
            persistedPhoto.visitLog = log
            log.photos.append(persistedPhoto)
        }

        // Keep legacy field empty now that multi-photo relation is canonical.
        log.photoData = nil
    }

    private func isVisitDateDescending(_ lhs: CastleVisitLogEntry, _ rhs: CastleVisitLogEntry) -> Bool {
        let calendar = Calendar.current
        let lhsDay = calendar.startOfDay(for: lhs.date)
        let rhsDay = calendar.startOfDay(for: rhs.date)

        if lhsDay != rhsDay {
            return lhsDay > rhsDay
        }

        return lhs.date > rhs.date
    }
}
