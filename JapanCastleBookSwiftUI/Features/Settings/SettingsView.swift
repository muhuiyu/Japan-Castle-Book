import SwiftUI

enum AppearancePreference: String {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct SettingsView: View {
    @Binding var colorSchemePreference: String

    var body: some View {
        NavigationStack {
            List {
                Section(L10n.settingsAppearance) {
                    Picker(L10n.settingsAppearance, selection: $colorSchemePreference) {
                        Text(L10n.settingsAppearanceSystem).tag(AppearancePreference.system.rawValue)
                        Text(L10n.settingsAppearanceLight).tag(AppearancePreference.light.rawValue)
                        Text(L10n.settingsAppearanceDark).tag(AppearancePreference.dark.rawValue)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    NavigationLink(L10n.settingsReferences) {
                        ReferencesView()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L10n.settingsTitle)
        }
    }
}

private struct ReferencesView: View {
    private let references: [(title: String, url: String)] = [
        ("japan-stamp-hunt.com", "https://japan-stamp-hunt.com/theme/top100-castles/"),
        ("akiou.wordpress.com", "https://akiou.wordpress.com/2019/06/04/blog-zoku100stamp/"),
        ("100finecastles.com", "https://www.100finecastles.com"),
        ("jokaku.jp", "https://jokaku.jp"),
        ("日本の名城.com", "https://catsle-japan.com/100castle-stamp/")
    ]

    var body: some View {
        List {
            Section {
                Text(L10n.referencesSpecialThanks)
                    .font(.headline)
            }

            Section {
                ForEach(references, id: \.url) { item in
                    Link(destination: URL(string: item.url)!) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .foregroundStyle(.primary)
                            Text(item.url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.referencesTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
