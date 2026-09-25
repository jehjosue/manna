import SwiftUI

/// Guia passo-a-passo para adicionar widget do Manna à tela inicial.
struct AddWidgetGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    let steps = [
        WidgetGuideStep(
            number: 1,
            title: "Pressione e segure",
            description: "Mantenha seu dedo pressionado em uma área vazia da tela inicial (ou sobre o Manna)",
            icon: "hand.point.up.fill",
            color: Theme.wheat
        ),
        WidgetGuideStep(
            number: 2,
            title: "Toque em adicionar widget",
            description: "Quando o menu aparecer, selecione 'Editar Tela Inicial' ou toque o ícone de mais",
            icon: "plus.circle.fill",
            color: Theme.olive
        ),
        WidgetGuideStep(
            number: 3,
            title: "Procure Manna",
            description: "Procure pela seção 'Manna' e toque nela",
            icon: "magnifyingglass",
            color: Theme.terracotta
        ),
        WidgetGuideStep(
            number: 4,
            title: "Escolha o widget",
            description: "Selecione o tamanho que você quer (pequeno mostra XP do dia, grande mostra pão + óleo)",
            icon: "rectangle.portrait.fill",
            color: Theme.bread
        ),
        WidgetGuideStep(
            number: 5,
            title: "Adicione à tela",
            description: "Toque 'Adicionar Widget' e escolha a posição. Pronto!",
            icon: "checkmark.circle.fill",
            color: Theme.manna
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Adicionar Widget")
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

                    // MARK: - Indicador de progresso
                    HStack(spacing: 0) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i <= currentStep ? Theme.wheat : Theme.line)
                                .frame(height: 4)
                                .transition(.scale)
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: - Conteúdo do passo
                    ScrollView {
                        VStack(spacing: 24) {
                            let step = steps[currentStep]

                            // Ícone grande
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(step.color.opacity(0.15))
                                    .frame(height: 120)

                                Image(systemName: step.icon)
                                    .font(.system(size: 56, weight: .semibold))
                                    .foregroundStyle(step.color)
                            }
                            .padding(.horizontal, 32)

                            // Número e título
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Passo \(step.number)")
                                        .font(Theme.font(12, .heavy))
                                        .foregroundStyle(Theme.wheat)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Theme.card)
                                        .cornerRadius(6)

                                    Spacer()
                                }
                                .padding(.horizontal, 16)

                                Text(step.title)
                                    .font(Theme.font(24, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)
                            }

                            // Descrição
                            Text(step.description)
                                .font(Theme.font(15, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)

                            Spacer(minLength: 32)
                        }
                        .padding(.vertical, 16)
                    }

                    // MARK: - Botões de navegação
                    HStack(spacing: 12) {
                        if currentStep > 0 {
                            Button {
                                withAnimation {
                                    currentStep -= 1
                                    SoundFX.play(.tap)
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .heavy))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                        }

                        if currentStep < steps.count - 1 {
                            Button {
                                withAnimation {
                                    currentStep += 1
                                    SoundFX.play(.tap)
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .heavy))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                        } else {
                            Button {
                                dismiss()
                            } label: {
                                Text("Feito!")
                                    .font(Theme.font(14, .heavy))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WidgetGuideStep {
    let number: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    AddWidgetGuideView()
}
