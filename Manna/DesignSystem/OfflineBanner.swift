import SwiftUI
import Network
import Observation

/// Estado da conexão com a internet (para telas que dependem de nuvem: ligas, grupos, amigos).
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isOnline = true
    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { self?.isOnline = path.status == .satisfied }
        }
        monitor.start(queue: DispatchQueue(label: "manna.network"))
    }
}

/// Faixa "sem conexão". Coloque no topo de telas online; some sozinha quando a internet volta.
struct OfflineBanner: View {
    private let network = NetworkMonitor.shared

    var body: some View {
        if !network.isOnline {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 16, weight: .bold))
                Text("Sem conexão. O que você estudar fica salvo e sincroniza depois.")
                    .font(Theme.font(13, .semibold))
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .foregroundStyle(Theme.ink)
            .padding(12)
            .background(Theme.line)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// Tela cheia "sem conexão" com a ovelhinha, para quando uma área inteira depende da internet.
struct OfflineStateView: View {
    var message = "Esta área precisa de internet. Suas lições continuam funcionando sem conexão."

    var body: some View {
        VStack(spacing: 16) {
            SheepView(mood: .sad, size: 110)
            Text("Sem conexão")
                .font(Theme.font(22, .heavy))
                .foregroundStyle(Theme.ink)
            Text(message)
                .font(Theme.font(15, .medium))
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
