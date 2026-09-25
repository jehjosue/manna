import SwiftUI
import StoreKit

/// Fluxo de cancelamento de assinatura com pesquisa e oferta antes de cancelar.
struct CancelSubscriptionFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cancellationReason: CancellationReason? = nil
    @State private var showOffer = false
    @State private var showConfirmation = false
    @State private var isProcessing = false

    enum CancellationReason: String, CaseIterable {
        case tooExpensive = "Muito caro"
        case noTime = "Não tenho tempo"
        case notUsing = "Não estou usando"
        case technical = "Problema técnico"
        case other = "Outro"

        var icon: String {
            switch self {
            case .tooExpensive: return "dollarsign.circle.fill"
            case .noTime: return "clock.fill"
            case .notUsing: return "eye.slash.fill"
            case .technical: return "wrench.and.screwdriver.fill"
            case .other: return "ellipsis"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Cancelar Assinatura")
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
                        VStack(spacing: 16) {
                            if cancellationReason == nil {
                                // MARK: - Seleção de motivo
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Desculpe por vê-lo ir 💔")
                                        .font(Theme.font(18, .heavy))
                                        .foregroundStyle(Theme.ink)

                                    Text("Por favor, nos diga o motivo para melhorar")
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(.horizontal, 16)

                                VStack(spacing: 12) {
                                    ForEach(CancellationReason.allCases, id: \.self) { reason in
                                        Button {
                                            cancellationReason = reason
                                            SoundFX.play(.tap)
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: reason.icon)
                                                    .foregroundStyle(Theme.terracotta)
                                                    .frame(width: 28)

                                                Text(reason.rawValue)
                                                    .font(Theme.font(14, .semibold))
                                                    .foregroundStyle(Theme.ink)

                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(Theme.inkMuted)
                                            }
                                            .padding(12)
                                            .background(Theme.card)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else {
                                // MARK: - Oferta de desconto
                                VStack(spacing: 16) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.yellow)

                                        Text("Espere um pouco!")
                                            .font(Theme.font(22, .heavy))
                                            .foregroundStyle(Theme.ink)

                                        Text("Temos uma oferta especial só para você")
                                            .font(Theme.font(14, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(16)
                                    .background(Theme.oliveLight)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)

                                    // Oferta visível apenas como texto, sem CTA de compra
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Oferta exclusiva:")
                                            .font(Theme.font(13, .heavy))
                                            .foregroundStyle(Theme.ink)
                                            .padding(.horizontal, 16)

                                        VStack(alignment: .leading, spacing: 6) {
                                            OfferItemRow(icon: "🎁", text: "1 mês com 50% de desconto")
                                            OfferItemRow(icon: "💰", text: "Apenas R$ 9,95 (em vez de R$ 19,90)")
                                            OfferItemRow(icon: "⏱", text: "Válido por 30 dias")
                                        }
                                        .padding(12)
                                        .background(Theme.card)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                    }

                                    Text("Você pode cancelar quando quiser após este período.")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 16)
                                }

                                // MARK: - Botões
                                VStack(spacing: 12) {
                                    Button {
                                        // Abrir gerenciador de assinatura
                                        if #available(iOS 17.2, *) {
                                            Task {
                                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                                    try? await AppStore.showManageSubscriptions(in: windowScene)
                                                }
                                            }
                                        }
                                    } label: {
                                        Text("Aceitar Oferta")
                                            .font(Theme.font(14, .heavy))
                                    }
                                    .buttonStyle(.chunky)

                                    Button {
                                        showConfirmation = true
                                    } label: {
                                        Text("Cancelar mesmo assim")
                                            .font(Theme.font(13, .medium))
                                            .foregroundStyle(Theme.night)
                                    }

                                    Button {
                                        cancellationReason = nil
                                        SoundFX.play(.tap)
                                    } label: {
                                        Text("Voltar")
                                            .font(Theme.font(13, .medium))
                                            .foregroundStyle(Theme.night)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 32)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Confirmar Cancelamento",
                isPresented: $showConfirmation,
                presenting: cancellationReason
            ) { reason in
                Button("Cancelar Assinatura", role: .destructive) {
                    performCancel()
                }
                Button("Não, voltar", role: .cancel) { }
            } message: { reason in
                Text("Você perderá acesso a óleo ilimitado e outros benefícios Plus. Tem certeza?")
            }
        }
    }

    private func performCancel() {
        isProcessing = true

        // A UI nativa do App Store será aberta via showManageSubscriptions
        if #available(iOS 17.2, *) {
            Task {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    try? await AppStore.showManageSubscriptions(in: windowScene)
                }
                isProcessing = false
                dismiss()
            }
        } else {
            isProcessing = false
        }
    }
}

struct OfferItemRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 16))
            Text(text)
                .font(Theme.font(13, .regular))
                .foregroundStyle(Theme.ink)
            Spacer()
        }
    }
}

#Preview {
    CancelSubscriptionFlowView()
}
