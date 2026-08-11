import Combine
import JapanCastleBook
import XCTest
@testable import JapanCastleBookSwiftUI

final class CastleListViewModelTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()

    func test_loadCastles_deliversCastlesOnSuccess() {
        let castles = [makeCastle(id: 1), makeCastle(id: 2)]
        let sut = CastleListViewModel(castleService: FakeCastleService(result: .success(castles)))

        let exp = expectation(description: "Wait for castles")
        sut.$castles.dropFirst().first().sink { _ in exp.fulfill() }.store(in: &subscriptions)

        sut.loadCastles()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(sut.castles, castles)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadCastles_deliversErrorMessageOnFailure() {
        let sut = CastleListViewModel(castleService: FakeCastleService(result: .failure(.connectivity)))

        let exp = expectation(description: "Wait for loading to finish")
        sut.$isLoading.dropFirst().filter { $0 == false }.first().sink { _ in exp.fulfill() }.store(in: &subscriptions)

        sut.loadCastles()
        wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(sut.castles.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadCastles_setsLoadingStateSynchronouslyThenClearsItOnCompletion() {
        let service = ManualCastleService()
        let sut = CastleListViewModel(castleService: service)

        sut.loadCastles()
        XCTAssertTrue(sut.isLoading)
        XCTAssertNil(sut.errorMessage)

        let castles = [makeCastle(id: 1)]
        let exp = expectation(description: "Wait for completion")
        sut.$isLoading.dropFirst().first().sink { _ in exp.fulfill() }.store(in: &subscriptions)

        service.complete(with: .success(castles))
        wait(for: [exp], timeout: 1.0)

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.castles, castles)
    }

    func test_loadCastles_clearsPreviousErrorMessageOnNewAttempt() {
        let service = ManualCastleService()
        let sut = CastleListViewModel(castleService: service)

        sut.loadCastles()
        let failureExp = expectation(description: "Wait for first failure")
        sut.$errorMessage.dropFirst().first().sink { _ in failureExp.fulfill() }.store(in: &subscriptions)
        service.complete(with: .failure(.missingFile))
        wait(for: [failureExp], timeout: 1.0)
        XCTAssertNotNil(sut.errorMessage)

        sut.loadCastles()

        XCTAssertNil(sut.errorMessage, "errorMessage should be cleared synchronously as soon as a new load starts")
    }

    func test_sections_groupsByAreaSortedByAreaRawValue() {
        let sut = CastleListViewModel(castleService: FakeCastleService(result: .success([])))
        let castles = [
            makeCastle(id: 1, area: .kinki),
            makeCastle(id: 2, area: .hokkaidoTohoku)
        ]

        let sections = sut.sections(for: castles)

        XCTAssertEqual(sections.map(\.area), [.hokkaidoTohoku, .kinki])
    }

    func test_sections_chunksEachAreasCastlesIntoRowsOfThree() {
        let sut = CastleListViewModel(castleService: FakeCastleService(result: .success([])))
        let castles = (1...4).map { makeCastle(id: $0, area: .hokkaidoTohoku) }

        let sections = sut.sections(for: castles)

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].rows.map { $0.map(\.id) }, [[1, 2, 3], [4]])
    }

    func test_sections_deliversNoSectionsForEmptyCastles() {
        let sut = CastleListViewModel(castleService: FakeCastleService(result: .success([])))

        XCTAssertTrue(sut.sections(for: []).isEmpty)
    }
}
