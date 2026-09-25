import Foundation

/// Idioma do conteúdo bíblico (lições, histórias, rádio, conversas).
/// A interface segue o idioma do aparelho (String Catalog); o conteúdo existe em pt, en e es —
/// idiomas sem conteúdo próprio usam inglês.
enum ContentLanguage: String, CaseIterable, Identifiable {
    case pt, en, es

    var id: String { rawValue }

    /// Chave para o usuário escolher manualmente (Configurações). Vazio = automático.
    static let overrideKey = "manna.contentLanguage"

    static var current: ContentLanguage {
        if let raw = UserDefaults.standard.string(forKey: overrideKey), let lang = ContentLanguage(rawValue: raw) {
            return lang
        }
        return automatic
    }

    /// Primeiro idioma preferido do aparelho que tenha conteúdo; senão inglês.
    static var automatic: ContentLanguage {
        for identifier in Locale.preferredLanguages {
            let code = Locale(identifier: identifier).language.languageCode?.identifier ?? ""
            if let lang = ContentLanguage(rawValue: code) { return lang }
        }
        return .en
    }

    var displayName: String {
        switch self {
        case .pt: "Português"
        case .en: "English"
        case .es: "Español"
        }
    }

    /// Voz do narrador e reconhecimento de fala.
    var voiceCode: String {
        switch self {
        case .pt: "pt-BR"
        case .en: "en-US"
        case .es: "es-MX"
        }
    }

    /// Arquivo de conteúdo no idioma atual (`base.en.json`), caindo para o português (`base.json`).
    static func url(for base: String, bundle: Bundle = .main) -> URL? {
        let lang = current
        if lang != .pt, let url = bundle.url(forResource: "\(base).\(lang.rawValue)", withExtension: "json") {
            return url
        }
        return bundle.url(forResource: base, withExtension: "json")
    }
}
