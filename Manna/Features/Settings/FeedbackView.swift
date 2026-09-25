import SwiftUI
import StoreKit

/// Tela para enviar opinião ou relatar problema.
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .suggestion
    @State private var feedbackText = ""
    @State private var showThankYou = false
    @State private var isSubmitting = false

    enum FeedbackType: String, CaseIterable {
        case suggestion = "Sugestão"
        case bug = "Problema/Bug"
        case performance = "Lentidão"
        case content = "Conteúdo"
        case other = "Outro"

        var icon: String {
            switch self {
            case .suggestion: return "lightbulb.fill"
            case .bug: return "ant.fill"
            case .performance: return "hare.fill"
            case .content: return "book.fill"
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
                        Text("Seu Feedback")
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
                            // MARK: - Seletor de tipo
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tipo de Feedback")
                                    .font(Theme.font(14, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                Picker("Tipo", selection: $feedbackType) {
                                    ForEach(FeedbackType.allCases, id: \.self) { type in
                                        Label(type.rawValue, systemImage: type.icon).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Campo de texto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sua Mensagem")
                                    .font(Theme.font(14, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                TextEditor(text: $feedbackText)
                                    .font(Theme.font(14, .regular))
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(Theme.card)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(Theme.ink)
                            }

                            // MARK: - Botões
                            VStack(spacing: 12) {
                                Button {
                                    submitFeedback()
                                } label: {
                                    if isSubmitting {
                                        ProgressView()
                                            .tint(Theme.cream)
                                    } else {
                                        Text("Enviar Feedback")
                                            .font(Theme.font(14, .heavy))
                                    }
                                }
                                .buttonStyle(.chunky)
                                .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)

                                Divider()
                                    .padding(.horizontal, 16)

                                Button {
                                    openAppStoreReview()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text("Avaliar na App Store")
                                            .font(Theme.font(13, .heavy))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .foregroundStyle(Theme.night)
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                            Spacer(minLength: 32)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Obrigado!", isPresented: $showThankYou) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Seu feedback foi recebido. Obrigado por ajudar a melhorar o Manna!")
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true

        let text = feedbackText.trimmingCharacters(in: .whitespaces)
        let subject = "[\(feedbackType.rawValue)] Feedback do Manna"

        // Simular envio (em um app real, seria via backend)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let mailto = "mailto:contato@manna.app?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

            if let url = URL(string: mailto) {
                UIApplication.shared.open(url)
            }

            isSubmitting = false
            showThankYou = true
            SoundFX.play(.correct)
            Haptics.success()
        }
    }

    private func openAppStoreReview() {
        if #available(iOS 16.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}

#Preview {
    FeedbackView()
}
