import SwiftUI

struct MainTabView: View {
    let environment: CastleAppEnvironment
    @AppStorage("appearance_preference") private var appearancePreference = AppearancePreference.system.rawValue

    var body: some View {
        TabView {
            CastleListView(
                viewModel: CastleListViewModel(castleService: environment.castleService),
                stampAssetService: environment.castleStampAssetService
            )
            .tabItem {
                Label(L10n.tabCastles, systemImage: "rectangle.grid.2x2.fill")
            }

            SettingsView(colorSchemePreference: $appearancePreference)
                .tabItem {
                    Label(L10n.tabSettings, systemImage: "gearshape.fill")
                }
        }
        .tint(.mint)
        .preferredColorScheme(AppearancePreference(rawValue: appearancePreference)?.colorScheme)
    }
}

#Preview {
    MainTabView(environment: .live)
        .environmentObject(CastleExperienceStore())
}
