import SwiftUI
import SwiftData

@main
struct JapanCastleBookSwiftUIApp: App {
    private let environment = CastleAppEnvironment.live
    private let modelContainer: ModelContainer
    @StateObject private var experienceStore: CastleExperienceStore

    init() {
        let container = CastleExperienceStore.makeAppModelContainer()
        self.modelContainer = container
        _experienceStore = StateObject(wrappedValue: CastleExperienceStore(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(environment: environment)
                .environmentObject(experienceStore)
        }
        .modelContainer(modelContainer)
    }
}
