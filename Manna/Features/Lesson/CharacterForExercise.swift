import SwiftUI

/// Escolhe um personagem determinístico para um exercício baseado no ID.
/// Usa soma de unicodeScalars do ID para garantir consistência entre execuções.
func characterForExercise(_ exerciseId: String) -> MannaCharacter {
    let castMembers = MannaCharacter.cast
    guard !castMembers.isEmpty else { return .bee }

    let sum = exerciseId.unicodeScalars.reduce(0) { sum, scalar in
        sum &+ UInt32(scalar.value)
    }
    let index = Int(sum) % castMembers.count
    return castMembers[index]
}
