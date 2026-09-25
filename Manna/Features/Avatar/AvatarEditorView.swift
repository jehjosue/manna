import SwiftUI

struct AvatarEditorView: View {
    @Environment(GameState.self) var game
    @Environment(AvatarStore.self) var avatarStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        Spacer()
                        Text("Editar Avatar")
                            .font(Theme.font(18, .bold))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Color.clear.frame(width: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    // Preview grande
                    SheepAvatarView(size: 160)
                        .padding(.vertical, 24)

                    // Abas
                    Picker("Categoria", selection: $selectedTab) {
                        Text("Lã").tag(0)
                        Text("Cabeça").tag(1)
                        Text("Pescoço").tag(2)
                        Text("Rosto").tag(3)
                        Text("Acessórios").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Conteúdo por aba
                    ScrollView {
                        VStack(spacing: 12) {
                            switch selectedTab {
                            case 0:
                                WoolColorTab()
                            case 1:
                                AccessoryTab(category: "Cabeça")
                            case 2:
                                AccessoryTab(category: "Pescoço")
                            case 3:
                                AccessoryTab(category: "Rosto")
                            case 4:
                                AccessoryTab(category: "Acessórios")
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct WoolColorTab: View {
    @Environment(GameState.self) var game
    @Environment(AvatarStore.self) var avatarStore

    var body: some View {
        VStack(spacing: 12) {
            ForEach(WoolColor.allCases, id: \.rawValue) { color in
                HStack {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().strokeBorder(Theme.line, lineWidth: 2))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(color.displayName)
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.ink)

                        if color.price > 0 {
                            HStack(spacing: 4) {
                                GameIconView(icon: .manna, size: 14)
                                Text("\(color.price)")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.manna)
                            }
                        } else {
                            Text("Grátis")
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.olive)
                        }
                    }

                    Spacer()

                    if avatarStore.woolColor == color {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(color.swiftUIColor)
                    } else {
                        Button(action: {
                            if avatarStore.changeWoolColor(color, game: game) {
                                SoundFX.play(.tap)
                                Haptics.tap()
                            }
                        }) {
                            Text("Usar")
                                .font(Theme.font(12, .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.wheat)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Theme.card)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            avatarStore.woolColor == color ? color.swiftUIColor : Theme.line,
                            lineWidth: avatarStore.woolColor == color ? 2 : 1
                        )
                )
            }
        }
    }
}

struct AccessoryTab: View {
    let category: String
    @Environment(GameState.self) var game
    @Environment(AvatarStore.self) var avatarStore

    var filteredAccessories: [Accessory] {
        avatarStore.allAccessories.filter { $0.type.category == category }
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(filteredAccessories) { accessory in
                HStack {
                    Image(systemName: accessory.type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Theme.wheat)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(accessory.displayName)
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.ink)

                        if accessory.price > 0 {
                            HStack(spacing: 4) {
                                GameIconView(icon: .manna, size: 14)
                                Text("\(accessory.price)")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.manna)
                            }
                        } else {
                            Text("Grátis")
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.olive)
                        }
                    }

                    Spacer()

                    if avatarStore.isOwned(accessory) {
                        if avatarStore.isEquipped(accessory) {
                            Button(action: {
                                avatarStore.unequipAccessory(accessory)
                                SoundFX.play(.tap)
                                Haptics.tap()
                            }) {
                                Text("Remover")
                                    .font(Theme.font(11, .bold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Theme.line.opacity(0.3))
                                    .cornerRadius(6)
                            }
                        } else {
                            Button(action: {
                                avatarStore.equipAccessory(accessory)
                                SoundFX.play(.tap)
                                Haptics.tap()
                            }) {
                                Text("Equipar")
                                    .font(Theme.font(11, .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Theme.wheat)
                                    .cornerRadius(6)
                            }
                        }
                    } else {
                        Button(action: {
                            if avatarStore.buyAccessory(accessory, game: game) {
                                avatarStore.equipAccessory(accessory)
                                SoundFX.play(.reward)
                                Haptics.success()
                            }
                        }) {
                            HStack(spacing: 4) {
                                GameIconView(icon: .manna, size: 14)
                                Text("Comprar")
                                    .font(Theme.font(11, .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(game.manna >= accessory.price ? Theme.wheat : Theme.line)
                            .cornerRadius(6)
                        }
                        .disabled(game.manna < accessory.price)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Theme.card)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(avatarStore.isEquipped(accessory) ? Theme.wheat : Theme.line, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    AvatarEditorView()
        .environment(GameState.load())
        .environment(AvatarStore.shared)
}
