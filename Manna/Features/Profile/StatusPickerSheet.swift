import SwiftUI

struct StatusPickerSheet: View {
    @Binding var selectedStatus: String
    @Environment(\.dismiss) var dismiss

    private let statusSuggestions = [
        "📖 Lendo Salmos",
        "🙏 Em oração",
        "✝️ Firme na fé",
        "💪 Estudando a Bíblia",
        "😊 Feliz no Senhor",
        "🌟 Crescendo",
        "❤️ Amando",
        "⛪ Na comunidade",
    ]

    @State private var customStatus: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        Spacer()
                        Text("Status")
                            .font(Theme.font(18, .bold))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Color.clear.frame(width: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    ScrollView {
                        VStack(spacing: 16) {
                            // Campo de texto customizado
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status customizado (máx. 30 caracteres)")
                                    .font(Theme.font(12, .bold))
                                    .foregroundStyle(Theme.inkMuted)

                                TextField("Digite seu status...", text: $customStatus)
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .placeholder(when: customStatus.isEmpty) {
                                        Text("Digite seu status...")
                                            .font(Theme.font(14, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    .onChange(of: customStatus) { _, newValue in
                                        if newValue.count > 30 {
                                            customStatus = String(newValue.prefix(30))
                                        }
                                    }
                                    .padding(12)
                                    .background(Theme.card)
                                    .cornerRadius(10)

                                HStack {
                                    Spacer()
                                    Text("\(customStatus.count)/30")
                                        .font(Theme.font(11, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                            }
                            .padding(.horizontal, 16)

                            if !customStatus.isEmpty {
                                Button(action: {
                                    selectedStatus = customStatus
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(customStatus)
                                            .font(Theme.font(16, .semibold))
                                        Spacer()
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.card)
                                    .foregroundStyle(Theme.ink)
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal, 16)
                            }

                            // Sugestões
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sugestões")
                                    .font(Theme.font(14, .bold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                VStack(spacing: 8) {
                                    ForEach(statusSuggestions, id: \.self) { status in
                                        Button(action: {
                                            selectedStatus = status
                                            dismiss()
                                        }) {
                                            HStack {
                                                Text(status)
                                                    .font(Theme.font(15, .semibold))
                                                    .foregroundStyle(Theme.ink)
                                                Spacer()
                                                if selectedStatus == status {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundStyle(Theme.wheat)
                                                }
                                            }
                                            .padding(12)
                                            .background(selectedStatus == status ? Theme.wheat.opacity(0.2) : Theme.card)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            // Botão Limpar
                            if !selectedStatus.isEmpty {
                                Button(action: {
                                    selectedStatus = ""
                                    customStatus = ""
                                    dismiss()
                                }) {
                                    Text("Remover Status")
                                        .font(Theme.font(14, .bold))
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.chunky)
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                customStatus = selectedStatus
            }
        }
    }
}

#Preview {
    StatusPickerSheet(selectedStatus: .constant("📖 Lendo Salmos"))
}
