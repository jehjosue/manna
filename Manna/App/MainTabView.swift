import SwiftUI

/// Navegação principal (6 abas, como o Duolingo):
/// Início · Praticar · Ligas · Missões · Loja · Perfil.
struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(AppTab.home)
                .tabItem { Label("Início", systemImage: "house.fill") }

            PracticeHubView()
                .tag(AppTab.practice)
                .tabItem { Label("Praticar", systemImage: "dumbbell.fill") }

            LeaguesView()
                .tag(AppTab.leagues)
                .tabItem { Label("Ligas", systemImage: "trophy.fill") }

            QuestsView()
                .tag(AppTab.quests)
                .tabItem { Label("Missões", systemImage: "checklist") }

            ShopView()
                .tag(AppTab.shop)
                .tabItem { Label("Loja", systemImage: "bag.fill") }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem { Label("Perfil", systemImage: "person.crop.circle.fill") }
        }
        .tint(Theme.wheat)
        .environment(\.selectAppTab) { selection = $0 }
    }
}

enum AppTab: Hashable {
    case home, practice, leagues, quests, shop, profile
}

// MARK: - Trocar de aba de qualquer tela: `@Environment(\.selectAppTab) var selectTab` → `selectTab(.shop)`

private struct SelectAppTabKey: EnvironmentKey {
    static let defaultValue: (AppTab) -> Void = { _ in }
}

extension EnvironmentValues {
    var selectAppTab: (AppTab) -> Void {
        get { self[SelectAppTabKey.self] }
        set { self[SelectAppTabKey.self] = newValue }
    }
}
