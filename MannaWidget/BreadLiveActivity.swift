import ActivityKit
import SwiftUI
import WidgetKit

struct BreadLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreadActivityAttributes.self) { context in
            // Lock screen view
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xD0643F))

                    Text("Seu pão diário de \(context.state.breadDays) dias está em risco")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x3D3326))

                    Spacer()
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: 0x8C8170))

                    Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x8C8170))

                    Spacer()
                }
            }
            .padding(12)
            .background(Color(hex: 0xFFF9EF))
            .cornerRadius(12)
        } dynamicIsland: { context in
            DynamicIslandExpandedRegion(context: context)
        }
    }
}

// MARK: - Dynamic Island Regions

struct DynamicIslandExpandedRegion: View {
    let context: ActivityViewContext<BreadActivityAttributes>

    var body: some View {
        DynamicIsland {
            VStack(spacing: 12) {
                // Expanded view: leading, trailing, bottom
                HStack(spacing: 12) {
                    // Leading
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pão em Risco")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0x3D3326))

                        Text("\(context.state.breadDays) dias")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0xD98E3A))
                    }

                    Spacer()

                    // Trailing
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Até meia-noite")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: 0x8C8170))

                        Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0xD0643F))
                    }
                }

                // Bottom: estudou?
                HStack(spacing: 8) {
                    Image(systemName: context.state.studied ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 12))
                        .foregroundStyle(context.state.studied ? Color(hex: 0x7A9A3A) : Color(hex: 0xD0643F))

                    Text(context.state.studied ? "Pão garantido!" : "Estude hoje para garantir")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x3D3326))

                    Spacer()
                }
            }
            .padding(12)
            .background(Color(hex: 0xFFF9EF))
        } compactLeading: {
            Image(systemName: "flame.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(hex: 0xD0643F))
        } compactTrailing: {
            Text("\(context.state.breadDays)")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(hex: 0xD98E3A))
        } minimal: {
            Image(systemName: "flame.fill")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(Color(hex: 0xD0643F))
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
