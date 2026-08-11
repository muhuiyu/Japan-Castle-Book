import SwiftData
import Testing
import UIKit
@testable import JapanCastleBookSwiftUI

@MainActor
struct CastleExperienceStoreTests {
    @Test func hasVisited_isFalseForUnknownCastle() {
        let sut = makeSUT()

        #expect(sut.hasVisited(1) == false)
        #expect(sut.hasStamp(1) == false)
        #expect(sut.visitLogs(for: 1).isEmpty)
    }

    @Test func addDigitalStamp_marksCastleAsVisitedAndStamped() {
        let sut = makeSUT()

        sut.addDigitalStamp(for: 1)

        #expect(sut.hasVisited(1) == true)
        #expect(sut.hasStamp(1) == true)
        #expect(sut.stampPhoto(for: 1) == nil)
    }

    @Test func setStampPhoto_persistsAndReloadsPhoto() {
        let sut = makeSUT()
        let image = makeImage()

        sut.setStampPhoto(for: 1, image: image)

        #expect(sut.hasStamp(1) == true)
        #expect(sut.stampPhoto(for: 1) != nil)
    }

    @Test func removeStamp_clearsStampButKeepsVisitLogs() {
        let sut = makeSUT()
        sut.addDigitalStamp(for: 1)
        sut.addVisitLog(for: 1, date: Date(), title: "title", content: "content", photos: [])

        sut.removeStamp(for: 1)

        #expect(sut.hasStamp(1) == false)
        #expect(sut.hasVisited(1) == true, "removing the stamp shouldn't remove visit logs")
        #expect(sut.visitLogs(for: 1).count == 1)
    }

    @Test func addVisitLog_appendsLogForCastle() {
        let sut = makeSUT()
        let date = Date()

        sut.addVisitLog(for: 1, date: date, title: "My visit", content: "It was great", photos: [])

        let logs = sut.visitLogs(for: 1)
        #expect(logs.count == 1)
        #expect(logs[0].title == "My visit")
        #expect(logs[0].content == "It was great")
    }

    @Test func visitLogs_areOrderedNewestFirst() {
        let sut = makeSUT()
        let older = Date(timeIntervalSince1970: 1000)
        let newer = Date(timeIntervalSince1970: 2000)

        sut.addVisitLog(for: 1, date: older, title: "older", content: "", photos: [])
        sut.addVisitLog(for: 1, date: newer, title: "newer", content: "", photos: [])

        let logs = sut.visitLogs(for: 1)
        #expect(logs.map(\.title) == ["newer", "older"])
    }

    @Test func updateVisitLog_changesFieldsForMatchingLog() {
        let sut = makeSUT()
        sut.addVisitLog(for: 1, date: Date(), title: "original", content: "original content", photos: [])
        let logID = sut.visitLogs(for: 1)[0].id
        let newDate = Date(timeIntervalSince1970: 5000)

        sut.updateVisitLog(for: 1, logID: logID, date: newDate, title: "updated", content: "updated content", photos: [])

        let logs = sut.visitLogs(for: 1)
        #expect(logs.count == 1)
        #expect(logs[0].title == "updated")
        #expect(logs[0].content == "updated content")
    }

    @Test func updateVisitLog_doesNothingForUnknownLogID() {
        let sut = makeSUT()
        sut.addVisitLog(for: 1, date: Date(), title: "original", content: "", photos: [])

        sut.updateVisitLog(for: 1, logID: UUID(), date: Date(), title: "should not apply", content: "", photos: [])

        #expect(sut.visitLogs(for: 1)[0].title == "original")
    }

    @Test func removeVisitLog_removesOnlyMatchingLog() {
        let sut = makeSUT()
        sut.addVisitLog(for: 1, date: Date(), title: "keep", content: "", photos: [])
        sut.addVisitLog(for: 1, date: Date(), title: "remove", content: "", photos: [])
        let idToRemove = sut.visitLogs(for: 1).first { $0.title == "remove" }!.id

        sut.removeVisitLog(for: 1, logID: idToRemove)

        let logs = sut.visitLogs(for: 1)
        #expect(logs.count == 1)
        #expect(logs[0].title == "keep")
    }

    @Test func experiences_areIsolatedPerCastle() {
        let sut = makeSUT()

        sut.addDigitalStamp(for: 1)

        #expect(sut.hasVisited(1) == true)
        #expect(sut.hasVisited(2) == false)
    }
}

@MainActor
extension CastleExperienceStoreTests {
    private func makeSUT() -> CastleExperienceStore {
        let schema = Schema([PersistedCastleExperience.self, PersistedVisitLog.self, PersistedVisitLogPhoto.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return CastleExperienceStore(modelContainer: container)
    }

    private func makeImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
    }
}
