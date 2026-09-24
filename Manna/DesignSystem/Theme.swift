import SwiftUI
import UIKit

/// Paleta e tipografia do Manna. Nada de verde-limão/azul Duolingo:
/// base dourado-trigo, verde-oliva para acerto, terracota para erro, fundo creme.
enum Theme {
    // Cores principais
    static let wheat = Color(hex: 0xE8A33D)          // dourado do trigo (primária)
    static let wheatDark = Color(hex: 0xB97A1E)      // sombra 3D da primária
    static let olive = Color(hex: 0x7A9A3A)          // acerto
    static let oliveDark = Color(hex: 0x5A7526)
    static let oliveLight = Color(light: 0xEEF3DF, dark: 0x2C3520)     // fundo da faixa de acerto
    static let terracotta = Color(hex: 0xD0643F)     // erro
    static let terracottaDark = Color(hex: 0xA2482A)
    static let terracottaLight = Color(light: 0xFBE6DD, dark: 0x3F2720) // fundo da faixa de erro
    static let night = Color(hex: 0x3B5BA9)          // azul-noite (secundária, info)
    static let nightDark = Color(hex: 0x2A4380)

    // Neutros
    static let cream = Color(light: 0xFFF9EF, dark: 0x1C1813)          // fundo do app
    static let card = Color(light: 0xFFFFFF, dark: 0x28231D)
    static let ink = Color(light: 0x3D3326, dark: 0xF3EBDD)            // texto principal
    static let inkMuted = Color(light: 0x8C8170, dark: 0xA99D8A)       // texto secundário
    static let line = Color(light: 0xE6DED0, dark: 0x3B342B)           // bordas / trilha bloqueada
    static let lineDark = Color(light: 0xCFC4B1, dark: 0x4D453A)       // sombra 3D de itens neutros

    // Ícones de gamificação
    static let bread = Color(hex: 0xD98E3A)          // pão diário (sequência)
    static let manna = Color(hex: 0xC9A227)          // moeda maná
    static let oil = Color(hex: 0xE0A526)            // óleo da lamparina (vidas)
    static let rest = Color(hex: 0x7FA7D9)           // dia de descanso (protege a sequência)

    // Tipografia: SF Rounded (sistema), diferente da fonte do Duolingo
    static func font(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let corner: CGFloat = 18
    static let depth: CGFloat = 5   // altura da "sombra 3D" dos botões
}

extension Color {
    /// Cor que muda sozinha entre o modo claro e o escuro.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }

    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
