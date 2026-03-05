import SwiftUI

@main
struct JapanCastleBookSwiftUIApp: App {
    private let environment = CastleAppEnvironment.live
    @StateObject private var experienceStore = CastleExperienceStore()

    var body: some Scene {
        WindowGroup {
            MainTabView(environment: environment)
                .environmentObject(experienceStore)
        }
    }
}
