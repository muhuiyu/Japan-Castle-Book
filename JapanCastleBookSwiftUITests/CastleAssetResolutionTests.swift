import Combine
import JapanCastleBook
import UIKit
import XCTest
@testable import JapanCastleBookSwiftUI

/// Guards against castle data referencing stamp/gosyuin image names that don't
/// actually exist in the compiled asset catalog (this is the class of bug that let
/// 11 castles silently fall back to a generic placeholder stamp).
final class CastleAssetResolutionTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()

    func test_everyCastleStampImageName_resolvesInAssetCatalog() {
        let castles = loadCastles()
        XCTAssertFalse(castles.isEmpty, "Precondition: expected castles.json to load castles")

        for castle in castles {
            guard let stampImageName = castle.stampImageName else { continue }

            XCTAssertNotNil(
                UIImage(named: stampImageName),
                "Castle \(castle.id) (\(castle.name)) references stamp image '\(stampImageName)' which is missing from the asset catalog"
            )
        }
    }

    func test_everyCastleGosyuinImageName_resolvesInAssetCatalog() {
        let castles = loadCastles()
        XCTAssertFalse(castles.isEmpty, "Precondition: expected castles.json to load castles")

        for castle in castles {
            for gosyuinImageName in castle.gosyuinImageNames {
                XCTAssertNotNil(
                    UIImage(named: gosyuinImageName),
                    "Castle \(castle.id) (\(castle.name)) references gosyuin image '\(gosyuinImageName)' which is missing from the asset catalog"
                )
            }
        }
    }
}

extension CastleAssetResolutionTests {
    private func loadCastles(file: StaticString = #filePath, line: UInt = #line) -> [Castle] {
        let exp = expectation(description: "Wait for loading")
        var result: [Castle] = []

        CastleAppEnvironment.live.castleService.load()
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Expected to load castles, got \(error) instead", file: file, line: line)
                }
                exp.fulfill()
            } receiveValue: { castles in
                result = castles
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 1.0)
        return result
    }
}
