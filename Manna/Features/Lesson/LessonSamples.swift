import Foundation

// MARK: - Dados de exemplo para Preview

extension Lesson {
    static let sampleLesson = Lesson(
        id: "sample-01",
        title: "Vida de Jesus",
        icon: "star.fill",
        exercises: [
            Exercise(
                id: "ex-1",
                kind: .multipleChoice,
                prompt: "Qual foi o primeiro milagre de Jesus?",
                speaker: "Narrador",
                text: "Qual foi o primeiro milagre de Jesus de acordo com o evangelho de João?",
                reference: "João 2:1-11",
                options: ["Transformar água em vinho", "Acalmar a tempestade", "Multiplicar os pães", "Curar um leproso"],
                answer: "Transformar água em vinho",
                tokens: nil,
                distractors: nil,
                pairs: nil,
                statement: nil,
                isTrue: nil,
                explanation: "Na festa de Caná, Jesus transformou água em vinho, seu primeiro milagre."
            ),
            Exercise(
                id: "ex-2",
                kind: .buildVerse,
                prompt: "Complete o versículo",
                speaker: nil,
                text: "Porque Deus ___ o mundo que muito ___ , que deu o seu ___.",
                reference: "João 3:16",
                options: nil,
                answer: nil,
                tokens: ["amou", "amado", "Filho"],
                distractors: ["odiou", "viu", "servo", "profeta"],
                pairs: nil,
                statement: nil,
                isTrue: nil,
                explanation: "Este é um dos versículos mais conhecidos da Bíblia."
            ),
            Exercise(
                id: "ex-3",
                kind: .matchPairs,
                prompt: "Associe os pares corretamente",
                speaker: nil,
                text: nil,
                reference: nil,
                options: nil,
                answer: nil,
                tokens: nil,
                distractors: nil,
                pairs: [
                    MatchPair(left: "Pedro", right: "Pescador"),
                    MatchPair(left: "Mateus", right: "Cobrador de impostos"),
                    MatchPair(left: "João", right: "Discípulo amado")
                ],
                statement: nil,
                isTrue: nil,
                explanation: "Os apóstolos tinham diferentes profissões antes de seguir Jesus."
            ),
            Exercise(
                id: "ex-4",
                kind: .trueFalse,
                prompt: "Verdadeiro ou falso?",
                speaker: nil,
                text: nil,
                reference: "Mateus 14:22-33",
                options: nil,
                answer: nil,
                tokens: nil,
                distractors: nil,
                pairs: nil,
                statement: "Jesus caminhou sobre as águas do mar da Galileia",
                isTrue: true,
                explanation: "Jesus caminhou sobre as águas para encontrar seus discípulos no barco."
            ),
            Exercise(
                id: "ex-5",
                kind: .multipleChoice,
                prompt: "Quantos apóstolos Jesus escolheu?",
                speaker: nil,
                text: "Jesus escolheu quantos apóstolos principais?",
                reference: "Mateus 10:1-4",
                options: ["10", "12", "15", "20"],
                answer: "12",
                tokens: nil,
                distractors: nil,
                pairs: nil,
                statement: nil,
                isTrue: nil,
                explanation: "Jesus escolheu 12 apóstolos para estar com ele e pregarem."
            )
        ]
    )
}
