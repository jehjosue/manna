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
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pão em risco")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                        Text("\(context.state.breadDays) dias")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0xD98E3A))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Até meia-noite")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(timerInterval: Date()...context.state.deadline, countsDown: true)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0xD0643F))
                            .multilineTextAlignment(.trailing)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.studied ? "checkmark.circle.fill" : "book.fill")
                            .foregroundStyle(context.state.studied ? Color(hex: 0x7A9A3A) : Color(hex: 0xE8A33D))
                        Text(context.state.studied ? "Pão garantido!" : "Faça uma lição para guardar seu pão")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color(hex: 0xD0643F))
            } compactTrailing: {
                Text("\(context.state.breadDays)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: 0xD98E3A))
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color(hex: 0xD0643F))
            }
        }
    }
}
