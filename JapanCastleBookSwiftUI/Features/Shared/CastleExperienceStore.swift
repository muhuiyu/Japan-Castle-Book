import SwiftUI
import JapanCastleBook

struct CastleVisitLogEntry: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let content: String
    let photo: UIImage?

    init(
        id: UUID = UUID(),
        date: Date,
        title: String,
        content: String,
        photo: UIImage?
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.photo = photo
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
        storage[castleID]?.visitLogs.sorted(by: { $0.date > $1.date }) ?? []
    }

    func addDigitalStamp(for castleID: CastleID) {
        update(castleID) { $0.hasDigitalStamp = true }
    }

    func setStampPhoto(for castleID: CastleID, image: UIImage) {
        update(castleID) {
            $0.stampPhoto = image
            $0.hasDigitalStamp = true
        }
    }

    func removeStamp(for castleID: CastleID) {
        update(castleID) {
            $0.hasDigitalStamp = false
            $0.stampPhoto = nil
        }
    }

    func addVisitLog(
        for castleID: CastleID,
        date: Date,
        title: String,
        content: String,
        photo: UIImage?
    ) {
        update(castleID) {
            $0.visitLogs.append(
                CastleVisitLogEntry(
                    date: date,
                    title: title,
                    content: content,
                    photo: photo
                )
            )
        }
    }

    private func update(_ castleID: CastleID, mutate: (inout CastleExperience) -> Void) {
        var experience = storage[castleID] ?? CastleExperience()
        mutate(&experience)
        storage[castleID] = experience
    }
}
