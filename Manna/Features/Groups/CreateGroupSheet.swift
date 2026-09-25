import SwiftUI

/// Sheet para criar um novo grupo.
struct CreateGroupSheet: View {
    @Environment(GameState.self) private var game
    @State private var service = GroupsService.shared

    @Binding var isPresented: Bool

    @State private var groupName = ""
    @State private var selectedGoal: Int = 500
    @State private var isCreating = false
    @State private var newGroup: MannaGroup?
    @State private var showSuccess = false

    private let goalOptions = [200, 500, 1000, 2000]

    var canCreate: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !isCreating
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                if let group = newGroup {
                    successView(group: group)
                } else {
                    formView
                }
            }
            .navigationTitle("Criar Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .disabled(isCreating)
                }
            }
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 20) {
                SheepView(mood: .happy, size: 100)
                    .padding(.top, 12)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nome do grupo")
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.ink)

                        TextField("Ex: Célula da Comunidade", text: $groupName)
                            .font(Theme.font(16, .semibold))
                            .padding(12)
                            .background(Theme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.line, lineWidth: 2)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meta semanal de XP")
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.ink)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(goalOptions, id: \.self) { goal in
                                GoalOptionButton(
                                    label: "\(goal) XP",
                                    isSelected: selectedGoal == goal,
                                    action: { selectedGoal = goal }
                                )
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descrição")
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.inkMuted)

                        Text("Você receberá um código único (6 caracteres) que pode compartilhar com os membros. Não será possível mudar o nome depois.")
                            .font(Theme.font(13, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
                .padding(16)
                .background(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Theme.line, lineWidth: 2)
                )
                .padding(.top, 8)

                Spacer()

                Button(action: { createGroup() }) {
                    if isCreating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Criar grupo")
                    }
                }
                .buttonStyle(.chunky)
                .disabled(!canCreate)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Success View

    private func successView(group: MannaGroup) -> some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                SheepView(mood: .cheering, size: 120)

                Text("Grupo criado com sucesso!")
                    .font(Theme.font(20, .bold))
                    .foregroundStyle(Theme.ink)

                Text("Seu grupo está pronto. Compartilhe o código com seus membros.")
                    .font(Theme.font(14, .regular))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(20)

            // Código grande e destacado
            VStack(spacing: 8) {
                Text("CÓDIGO")
                    .font(Theme.font(11, .bold))
                    .foregroundStyle(Theme.inkMuted)

                Text(group.code)
                    .font(Theme.font(40, .bold))
                    .tracking(4)
                    .foregroundStyle(Theme.wheat)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Theme.wheat, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)

            // Mensagem de convite
            VStack(spacing: 8) {
                Text("Convide membros")
                    .font(Theme.font(14, .bold))
                    .foregroundStyle(Theme.ink)

                Text("Vamos estudar a Bíblia juntos no Manna! Entre no meu grupo com o código \(group.code).")
                    .font(Theme.font(13, .regular))
                    .foregroundStyle(Theme.ink)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.oliveLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.olive, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)

            // Botão de compartilhar
            ShareLink(
                item: "Vamos estudar a Bíblia juntos no Manna! Entre no meu grupo com o código \(group.code).",
                subject: Text("Junte-se ao meu grupo no Manna")
            ) {
                Text("Compartilhar código")
            }
            .buttonStyle(.chunkyNight)
            .padding(.horizontal, 20)

            Spacer()

            Button(action: { isPresented = false }) {
                Text("Voltar")
            }
            .buttonStyle(.chunky)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Actions

    private func createGroup() {
        let name = groupName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        isCreating = true
        Task {
            let group = await service.createGroup(name: name, weeklyGoal: selectedGoal)

            DispatchQueue.main.async {
                self.newGroup = group
                isCreating = false
                if group != nil {
                    SoundFX.play(.reward)
                    Haptics.success()
                }
            }
        }
    }
}

// MARK: - Goal Option Button

struct GoalOptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Theme.font(14, .bold))
                .foregroundStyle(isSelected ? .white : Theme.ink)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(isSelected ? Theme.wheat : Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? Theme.wheat : Theme.line, lineWidth: 2)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    @State var isPresented = true
    return CreateGroupSheet(isPresented: $isPresented)
        .environment(GameState())
}
