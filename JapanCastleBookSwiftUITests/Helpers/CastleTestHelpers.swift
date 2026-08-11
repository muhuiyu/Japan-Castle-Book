import Combine
import Foundation
import JapanCastleBook

func makeCastle(
    id: Int = 0,
    name: String = "any name",
    area: CastleArea = .hokkaidoTohoku,
    stampImageName: String? = nil,
    gosyuinImageNames: [String] = []
) -> Castle {
    Castle(
        id: id,
        name: name,
        reading: "any reading",
        area: area,
        address: "any address",
        phoneNumber: "any phone number",
        openingHours: "any opening hours",
        accessGuide: "any access guide",
        parkingInfo: "any parking info",
        stampLocation: "any stamp location",
        stampImageName: stampImageName,
        gosyuinImageNames: gosyuinImageNames,
        overview: "any overview",
        imageURLs: []
    )
}

final class FakeCastleService: CastleService {
    private let result: Result<[Castle], CastleServiceError>

    init(result: Result<[Castle], CastleServiceError>) {
        self.result = result
    }

    func load() -> AnyPublisher<[Castle], CastleServiceError> {
        result.publisher.eraseToAnyPublisher()
    }
}

/// A `CastleService` whose completion is triggered manually via `complete(with:)`,
/// for tests that need to inspect state before the publisher finishes.
final class ManualCastleService: CastleService {
    private let subject = PassthroughSubject<[Castle], CastleServiceError>()

    func load() -> AnyPublisher<[Castle], CastleServiceError> {
        subject.eraseToAnyPublisher()
    }

    func complete(with result: Result<[Castle], CastleServiceError>) {
        switch result {
        case let .success(castles):
            subject.send(castles)
            subject.send(completion: .finished)
        case let .failure(error):
            subject.send(completion: .failure(error))
        }
    }
}
