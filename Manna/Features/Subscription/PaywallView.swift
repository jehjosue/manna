import SwiftUI
import StoreKit

/// Paywall com 2 planos: mensal e anual (anual com desconto).
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isLoading = false
    @State private var showRestoreAlert = false

    let store = SubscriptionStore.shared

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 24) {
                // MARK: - Header com fechar
                HStack {
                    Text("Manna Plus")
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

                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Ovelhinha e headline
                        VStack(spacing: 12) {
                            SheepView(mood: .happy, size: 80)

                            Text("Apoie a jornada")
                                .font(Theme.font(24, .heavy))
                                .foregroundStyle(Theme.ink)

                            Text("Desfrute de benefícios exclusivos e ajude a manter Manna grátis para todos")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Lista de benefícios
                        VStack(spacing: 12) {
                            BenefitRow(icon: "bolt.fill", text: "Óleo ilimitado, estude quantas vezes quiser")
                            BenefitRow(icon: "checkmark.circle.fill", text: "Revisão ilimitada de erros")
                            BenefitRow(icon: "star.fill", text: "Ícone Plus no seu perfil")
                            BenefitRow(icon: "heart.fill", text: "Apoie o desenvolvimento do app")
                        }
                        .padding(16)
                        .background(Theme.oliveLight)
                        .cornerRadius(14)
                        .padding(.horizontal, 16)

                        // MARK: - Seletores de plano
                        VStack(spacing: 12) {
                            PlanCardView(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly,
                                onTap: { selectedPlan = .monthly }
                            )

                            PlanCardView(
                                plan: .yearly,
                                isSelected: selectedPlan == .yearly,
                                onTap: { selectedPlan = .yearly }
                            )
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Botão assinar
                        Button {
                            Task {
                                await purchaseSelected()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Assinar Agora")
                                }
                            }
                            .font(Theme.font(16, .heavy))
                        }
                        .buttonStyle(.chunky)
                        .disabled(isLoading)
                        .padding(.horizontal, 16)

                        // MARK: - Restaurar compras
                        Button {
                            showRestoreAlert = true
                        } label: {
                            Text("Restaurar Compras")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.night)
                        }

                        // MARK: - Links legais
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                Link(destination: URL(string: "https://manna.app/termos")!) {
                                    Text("Termos")
                                        .font(Theme.font(11, .medium))
                                        .foregroundStyle(Theme.night)
                                }

                                Link(destination: URL(string: "https://manna.app/privacidade")!) {
                                    Text("Privacidade")
                                        .font(Theme.font(11, .medium))
                                        .foregroundStyle(Theme.night)
                                }
                            }

                            Text("Renovação automática. Cancele a qualquer momento nas Configurações da Apple.")
                                .font(Theme.font(10, .regular))
                                .foregroundStyle(Theme.inkMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 20)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .alert("Restaurar Compras", isPresented: $showRestoreAlert) {
            Button("Restaurar") {
                Task {
                    isLoading = true
                    await store.restore()
                    isLoading = false
                    dismiss()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Isso sincronizará suas compras com a Apple.")
        }
    }

    private func purchaseSelected() async {
        isLoading = true
        defer { isLoading = false }

        let product = selectedPlan == .monthly ? store.monthlyProduct : store.yearlyProduct
        guard let product else { return }

        let success = await store.purchase(product)
        if success {
            SoundFX.play(.levelUp)
            Haptics.success()
            dismiss()
        } else {
            Haptics.error()
        }
    }
}

enum SubscriptionPlan {
    case monthly, yearly
}

struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Theme.olive)
                .frame(width: 24)

            Text(text)
                .font(Theme.font(13, .semibold))
                .foregroundStyle(Theme.ink)

            Spacer()
        }
    }
}

struct PlanCardView: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    var onTap: () -> Void

    let store = SubscriptionStore.shared

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(planTitle)
                            .font(Theme.font(16, .heavy))
                            .foregroundStyle(Theme.ink)

                        Text(planSubtitle)
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(planPrice)
                            .font(Theme.font(14, .heavy))
                            .foregroundStyle(Theme.wheat)

                        if plan == .yearly, let discount = yearlyDiscount {
                            Text("Economize \(discount)")
                                .font(Theme.font(10, .semibold))
                                .foregroundStyle(Theme.olive)
                        }
                    }
                }

                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.olive)

                        Text("Selecionado")
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.olive)

                        Spacer()
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Theme.oliveLight : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Theme.olive : Theme.line, lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    private var planTitle: String {
        plan == .monthly ? "Mensal" : "Anual"
    }

    private var planSubtitle: String {
        plan == .monthly ? "Renova todo mês" : "Melhor valor"
    }

    private var planPrice: String {
        if plan == .monthly {
            return store.monthlyProduct?.displayPrice ?? "R$ 19,90"
        } else {
            return store.yearlyProduct?.displayPrice ?? "R$ 119,90"
        }
    }

    private var yearlyDiscount: String? {
        guard plan == .yearly else { return nil }
        // Calcula economia: 12 × 19,90 - 119,90
        return "≈30%"
    }
}

#Preview {
    PaywallView()
}
