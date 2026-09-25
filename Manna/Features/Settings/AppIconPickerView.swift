import SwiftUI
import UIKit

/// Seletor de ícones alternativos do app.
struct AppIconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIcon: String? = nil
    @State private var showError = false
    @State private var errorMessage = ""

    let appIcons = [
        AppIconOption(id: nil, name: "Padrão", description: "Ícone original do Manna", systemImage: "square.fill", color: Theme.wheat),
        AppIconOption(id: "night", name: "Noite", description: "Tema escuro com tons de noite", systemImage: "moon.fill", color: Theme.night),
        AppIconOption(id: "olive", name: "Oliva", description: "Tom terroso e quente", systemImage: "leaf.fill", color: Theme.olive),
        AppIconOption(id: "light", name: "Trigo Claro", description: "Tons de trigo e creme", systemImage: "sun.max.fill", color: Theme.terracotta)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Ícone do App")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(appIcons, id: \.id) { icon in
                                IconOptionCard(
                                    icon: icon,
                                    isSelected: selectedIcon == icon.id,
                                    onSelect: { selectIcon(icon.id) }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Erro", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                getCurrentIcon()
            }
        }
    }

    private func getCurrentIcon() {
        // UIApplication.shared.alternateIconName retorna nil para o ícone padrão
        selectedIcon = UIApplication.shared.alternateIconName
    }

    private func selectIcon(_ iconName: String?) {
        Task {
            do {
                try await UIApplication.shared.setAlternateIconName(iconName)
                selectedIcon = iconName
                SoundFX.play(.tap)
                Haptics.success()
            } catch {
                errorMessage = "Não foi possível mudar o ícone. Tente novamente."
                showError = true
                SoundFX.play(.wrong)
                Haptics.error()
            }
        }
    }
}

struct AppIconOption: Identifiable, Hashable {
    let id: String?
    let name: String
    let description: String
    let systemImage: String
    let color: Color
}

struct IconOptionCard: View {
    let icon: AppIconOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(icon.color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon.systemImage)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(icon.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(icon.name)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(icon.description)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.olive)
                } else {
                    Circle()
                        .stroke(Theme.line, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(12)
            .background(isSelected ? Theme.oliveLight : Theme.card)
            .cornerRadius(12)
        }
    }
}

#Preview {
    AppIconPickerView()
}
