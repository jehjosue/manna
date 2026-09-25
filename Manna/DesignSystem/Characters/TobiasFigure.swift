import SwiftUI

/// Tobias — menino de 9 anos, pele clara com sardas, cabelo ruivo espetado, camiseta laranja, dente da frente faltando.
struct TobiasFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                // Corpo (camiseta laranja)
                Capsule()
                    .fill(Theme.terracotta)
                    .frame(width: size * 0.5, height: size * 0.35)
                    .offset(y: size * 0.15)

                // Ombros
                HStack(spacing: size * 0.22) {
                    Circle()
                        .fill(Theme.terracotta)
                        .frame(width: size * 0.12, height: size * 0.12)
                    Circle()
                        .fill(Theme.terracotta)
                        .frame(width: size * 0.12, height: size * 0.12)
                }
                .offset(y: size * 0.08)

                // Braços
                HStack(spacing: size * 0.48) {
                    Capsule()
                        .fill(Color(hex: 0xF4D4B8))
                        .frame(width: size * 0.08, height: size * 0.2)
                        .offset(x: -size * 0.08, y: size * 0.05)

                    Capsule()
                        .fill(Color(hex: 0xF4D4B8))
                        .frame(width: size * 0.08, height: size * 0.2)
                        .offset(x: size * 0.08, y: size * 0.05)
                }

                // Cabeça (círculo pele clara)
                Circle()
                    .fill(Color(hex: 0xF4D4B8))
                    .frame(width: size * 0.45, height: size * 0.45)
                    .offset(y: -size * 0.18)

                // Sardas na bochecha
                Circle()
                    .fill(Color(hex: 0xD4876B).opacity(0.6))
                    .frame(width: size * 0.04, height: size * 0.04)
                    .offset(x: -size * 0.12, y: -size * 0.12)

                Circle()
                    .fill(Color(hex: 0xD4876B).opacity(0.6))
                    .frame(width: size * 0.035, height: size * 0.035)
                    .offset(x: -size * 0.16, y: -size * 0.1)

                Circle()
                    .fill(Color(hex: 0xD4876B).opacity(0.6))
                    .frame(width: size * 0.03, height: size * 0.03)
                    .offset(x: size * 0.12, y: -size * 0.15)

                // Cabelo ruivo espetado
                cabeleiraRuiva(context.date)

                // Olhos
                olhoView(isLeft: true, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.7))
                olhoView(isLeft: false, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.7))

                // Boca conforme mood
                bocaView(context.date)
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private func cabeleiraRuiva(_ date: Date) -> some View {
        ZStack {
            // Topo espetado (3 pontas)
            TobiasSpike()
                .fill(Color(hex: 0xD2691E))
                .frame(width: size * 0.12, height: size * 0.18)
                .offset(x: -size * 0.08, y: -size * 0.3)
                .rotationEffect(.degrees(-15))

            TobiasSpike()
                .fill(Color(hex: 0xD2691E))
                .frame(width: size * 0.14, height: size * 0.22)
                .offset(x: 0, y: -size * 0.35)

            TobiasSpike()
                .fill(Color(hex: 0xD2691E))
                .frame(width: size * 0.12, height: size * 0.18)
                .offset(x: size * 0.08, y: -size * 0.3)
                .rotationEffect(.degrees(15))

            // Franja lateral
            Circle()
                .fill(Color(hex: 0xD2691E))
                .frame(width: size * 0.1, height: size * 0.08)
                .offset(x: -size * 0.15, y: -size * 0.22)
        }
    }

    private func olhoView(isLeft: Bool, date: Date, closed: Bool) -> some View {
        ZStack {
            if closed {
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.05)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.1, height: size * 0.11)

                Circle()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.05, height: size * 0.05)
                    .offset(y: size * 0.015)

                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.02, height: size * 0.02)
                    .offset(x: -size * 0.01, y: -size * 0.015)
            }
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.12)
    }

    @ViewBuilder
    private func bocaView(_ date: Date) -> some View {
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        switch mood {
        case .happy:
            // Sorriso com dente faltando
            VStack(spacing: 0) {
                // Linha do sorriso
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                    .frame(width: size * 0.14, height: size * 0.07)

                // Dente faltando: duas linhas verticais
                HStack(spacing: size * 0.04) {
                    Capsule()
                        .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.012)
                        .frame(width: size * 0.025, height: size * 0.035)

                    Capsule()
                        .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.012)
                        .frame(width: size * 0.025, height: size * 0.035)
                }
                .offset(y: size * 0.015)
            }
            .offset(y: size * 0.06)

        case .cheering:
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.12, height: size * 0.035)
                    .offset(y: size * 0.02)

                Text("O")
                    .font(Theme.font(size * 0.12, .heavy))
                    .foregroundStyle(Color(hex: 0x1A1A1A))
                    .offset(y: size * 0.05)
            }
            .offset(y: size * 0.06)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.12, height: size * 0.06)
                .rotationEffect(.degrees(25))
                .offset(y: size * 0.08)

        case .thinking:
            Text("?")
                .font(Theme.font(size * 0.1, .heavy))
                .foregroundStyle(Color(hex: 0x8C8170))
                .offset(y: size * 0.05)

        case .sleepy:
            ZStack {
                Text("z")
                    .font(Theme.font(size * 0.08, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .offset(x: size * 0.12, y: -size * 0.18)
            }

        case .surprised:
            Text("o")
                .font(Theme.font(size * 0.11, .heavy))
                .foregroundStyle(Color(hex: 0x1A1A1A))
                .offset(y: size * 0.06)
        }
    }
}


/// Mecha de cabelo espetado (triângulo com a ponta para cima).
private struct TobiasSpike: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
