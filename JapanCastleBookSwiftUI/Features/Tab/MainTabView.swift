import SwiftUI

struct MainTabView: View {
    let environment: CastleAppEnvironment

    var body: some View {
        TabView {
            CastleListView(
                viewModel: CastleListViewModel(castleService: environment.castleService),
                stampAssetService: environment.castleStampAssetService
            )
            .tabItem {
                Label(L10n.tabCastles, systemImage: "rectangle.grid.2x2.fill")
            }
        }
        .tint(.mint)
    }
}

#Preview {
    MainTabView(environment: .live)
        .environmentObject(CastleExperienceStore())
}
