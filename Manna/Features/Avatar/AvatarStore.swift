import Foundation
import SwiftUI
import Observation

// MARK: - Tipos de Accessories

enum WoolColor: String, CaseIterable, Codable {
    case white      // Branca (padrão, grátis)
    case cream      // Creme (grátis)
    case gray       // Cinza (grátis)
    case chocolate  // Chocolate (50 maná)

    var displayName: String {
        switch self {
        case .white: "Branca"
        case .cream: "Creme"
        case .gray: "Cinza"
        case .chocolate: "Chocolate"
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .white: Color.white
        case .cream: Color(hex: 0xFFF4E6)
        case .gray: Color(hex: 0xC0C0C0)
        case .chocolate: Color(hex: 0x8B5A3C)
        }
    }

    var price: Int {
        switch self {
        case .white, .cream, .gray: 0
        case .chocolate: 50
        }
    }
}

enum AccessoryType: String, CaseIterable, Codable {
    case shepherdHat       // Chapéu de pastor
    case flowerCrown       // Coroa de flores
    case scarf             // Cachecol
    case glasses           // Óculos redondos
    case bow               // Laço
    case staff             // Cajadinho
    case winterHat         // Gorro de inverno
    case bethlehemStar     // Estrela de Belém

    var displayName: String {
        switch self {
        case .shepherdHat: "Chapéu de Pastor"
        case .flowerCrown: "Coroa de Flores"
        case .scarf: "Cachecol"
        case .glasses: "Óculos Redondos"
        case .bow: "Laço"
        case .staff: "Cajadinho"
        case .winterHat: "Gorro de Inverno"
        case .bethlehemStar: "Estrela de Belém"
        }
    }

    var icon: String {
        switch self {
        case .shepherdHat: "hat.fill"
        case .flowerCrown: "crown.fill"
        case .scarf: "scarf.fill"
        case .glasses: "glasses"
        case .bow: "bow.fill"
        case .staff: "wand.and.stars"
        case .winterHat: "cap.fill"
        case .bethlehemStar: "star.fill"
        }
    }

    var price: Int {
        switch self {
        case .shepherdHat, .scarf, .glasses: 0  // Grátis
        case .flowerCrown, .staff: 30            // 30 maná
        case .bow, .winterHat: 50                // 50 maná
        case .bethlehemStar: 75                  // 75 maná
        }
    }

    var category: String {
        switch self {
        case .shepherdHat, .winterHat: "Cabeça"
        case .flowerCrown: "Cabeça"
        case .scarf: "Pescoço"
        case .glasses, .bow: "Rosto"
        case .staff: "Acessórios"
        case .bethlehemStar: "Brilho"
        }
    }
}

struct Accessory: Codable, Identifiable, Hashable {
    let id: String  // AccessoryType.rawValue
    let type: AccessoryType

    var displayName: String { type.displayName }
    var price: Int { type.price }
    var isFree: Bool { price == 0 }
}

// MARK: - Store Observable

@Observable
final class AvatarStore {
    static let shared = AvatarStore()

    private(set) var woolColor: WoolColor = .white { didSet { save() } }
    private(set) var equippedAccessories: Set<String> = [] { didSet { save() } }
    private(set) var ownedAccessories: Set<String> = [] { didSet { save() } }

    private let storageKey = "manna.avatar.v1"

    init() {
        // Carrega primeiro: inserir antes gravaria por cima das compras salvas.
        loadProgress()
        // Acessórios grátis sempre disponíveis
        for accessory in AccessoryType.allCases where accessory.price == 0 {
            ownedAccessories.insert(accessory.rawValue)
        }
    }

    var allAccessories: [Accessory] {
        AccessoryType.allCases.map { Accessory(id: $0.rawValue, type: $0) }
    }

    func isOwned(_ accessory: Accessory) -> Bool {
        ownedAccessories.contains(accessory.id)
    }

    func isEquipped(_ accessory: Accessory) -> Bool {
        equippedAccessories.contains(accessory.id)
    }

    func buyAccessory(_ accessory: Accessory, game: GameState) -> Bool {
        guard !isOwned(accessory) && accessory.price > 0 else { return false }
        guard game.spendManna(accessory.price) else { return false }
        ownedAccessories.insert(accessory.id)
        return true
    }

    func equipAccessory(_ accessory: Accessory) {
        guard isOwned(accessory) else { return }
        equippedAccessories.insert(accessory.id)
        save()
    }

    func unequipAccessory(_ accessory: Accessory) {
        equippedAccessories.remove(accessory.id)
        save()
    }

    func changeWoolColor(_ color: WoolColor, game: GameState) -> Bool {
        if color.price > 0 && !game.spendManna(color.price) { return false }
        woolColor = color
        save()
        return true
    }

    // MARK: - Privadas

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        woolColor = snapshot.woolColor
        equippedAccessories = snapshot.equippedAccessories
        ownedAccessories = snapshot.ownedAccessories
    }

    private func save() {
        let snapshot = Snapshot(
            woolColor: woolColor,
            equippedAccessories: equippedAccessories,
            ownedAccessories: ownedAccessories
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private struct Snapshot: Codable {
        var woolColor: WoolColor
        var equippedAccessories: Set<String>
        var ownedAccessories: Set<String>
    }
}
