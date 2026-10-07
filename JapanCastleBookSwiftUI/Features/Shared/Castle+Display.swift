import Foundation
import JapanCastleBook

extension Castle {
    /// English name when the app runs in a non-Japanese language and one is available,
    /// otherwise the Japanese name.
    var displayName: String {
        guard !Self.isJapaneseUI, let nameEN else { return name }
        return nameEN
    }

    /// Shown under the title: the reading in Japanese, or the original name and reading in English.
    var displaySubtitle: String {
        displayName == name ? reading : "\(name)（\(reading)）"
    }

    private static let isJapaneseUI = Bundle.main.preferredLocalizations.first?.hasPrefix("ja") == true
}
