import Foundation

enum FeatureFlags {
    /// Next 100 Castles (続日本100名城, IDs 101–200). Data is still being collected,
    /// so it is only visible in debug builds and hidden from release/App Store builds.
    static var nextHundredCastles: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
