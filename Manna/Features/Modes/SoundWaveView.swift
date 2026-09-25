import SwiftUI

/// Visualizador de onda sonora animada para o player de rádio.
struct SoundWaveView: View {
    @State private var barHeights: [CGFloat] = Array(repeating: 0.2, count: 12)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Theme.wheat, Theme.bread]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: 3, height: barHeights[index] * 30)
                    .animation(.easeInOut(duration: 0.1), value: barHeights[index])
            }
        }
        .onReceive(timer) { _ in
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.1)) {
                    barHeights = (0..<barHeights.count).map { _ in
                        CGFloat.random(in: 0.3...1)
                    }
                }
            }
        }
    }
}

#Preview {
    SoundWaveView()
        .frame(height: 40)
        .padding()
}
