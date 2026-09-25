# Regras para agentes que constroem o Manna

Projeto: C:\Users\domde\manna. É um app iOS em SwiftUI, com iOS 17 no mínimo e Swift 5 (SWIFT_VERSION "5.0"). O projeto é gerado pelo XcodeGen a partir de `project.yml`; todo arquivo .swift dentro de `Manna/` já entra no alvo sozinho. Os textos do app são em português do Brasil.
NÃO existe compilador nesta máquina (Windows). O código precisa compilar de primeira, então revise cada linha como se você fosse o compilador. Não rode git e não rode build.

## Identidade (NUNCA copiar nomes, cores ou personagens do Duolingo)
- Mascote: ovelhinha Béé, desenhada com `SheepView(mood: .happy|.cheering|.sad|.thinking|.sleepy, size:)`.
- Termos: pão diário = sequência; maná = moeda; óleo da lamparina = vidas; dia de descanso = protege a sequência; Manna Plus = assinatura; jornadas = cursos.
- Jesus nunca aparece como personagem cômico.
- Design:
  - `Theme` traz as cores wheat/olive/terracotta/night/cream/card/ink/inkMuted/line/lineDark/bread/manna/oil/rest e a fonte `Theme.font(size, .weight)`.
  - `.buttonStyle(.chunky)`, `.chunkyCorrect`, `.chunkyWrong`, `.chunkyNight`.
  - `ChoiceCard(isSelected:tint:)`, `StatBadge`, `GameIcon` com `GameIconView(icon:size:)`.
  - `SoundFX.play(.tap/.correct/.wrong/.reward/.levelUp/...)`, `Haptics.success()/error()/tap()`.
  - `Narrator.speak(texto, slow:)` para voz em pt-BR.
- Referência visual: Gummble MCP, app slug `duolingo-ios`. Carregue as ferramentas com ToolSearch "select:mcp__gummble__gummble_get_flow_screens_batch,mcp__gummble__gummble_get_screen_details_batch" e veja os fluxos pelos IDs indicados. Adapte o layout e a hierarquia; nunca a marca.

## Arquitetura
- Estado global:
  - `@Environment(GameState.self) private var game` traz xpTotal, xpToday, weeklyXP, bread, bestBread, manna, oil, isPlus, userName, studiedDays, lessons, mistakeIds, `completeActivity(_:kind:baseXP:)`, `addManna`, `spendManna`, etc. Leia Manna/Models/GameState.swift antes de usar qualquer membro.
  - `@Environment(ContentStore.self) private var content` traz journeys, journey (atual), stories, `lesson(id:)`, `exercise(id:)`.
  - Leia Manna/Models/Content.swift.
  - Também existem no ambiente: `AchievementStore.shared`, `AvatarStore.shared`, `LeagueStore.shared`, `GameCenterService.shared`.
- Seu estado novo fica num store próprio, na pasta da sua feature: `@Observable final class XStore { static let shared = XStore() }`, salvo em UserDefaults com a chave "manna.<nome>.v1". Acesse sempre por `XStore.shared`; NÃO use `@Environment` para stores novos.
- Compartilhados que já existem:
  - `ProfileIdentityStore.shared` (username, status, bio, joinedAt).
  - `NetworkMonitor.shared.isOnline`, `OfflineBanner()` e `OfflineStateView()`.
- Para abrir uma lição: `LessonView(lesson: Lesson, mode: .normal|.practice|.legendary, onFinish: { outcome in ... }, onQuit: { ... })` dentro de `.fullScreenCover`. No onFinish, chame `let result = game.completeActivity(outcome, kind: .lesson|.practice|.story|.challenge, baseXP: N)` e depois mostre `CelebrationFlowView(result: result, onDone: {...})`.
- Para criar uma lição sintética: `Lesson(id:title:icon:exercises:)`.

## Erros que já quebraram a compilação (não repetir)
- Previews: sem `@State` dentro de `#Preview`, sem `return` em `#Preview`, sem `@Previewable`. Use `.constant(...)`, ou simplesmente não crie preview.
- `.uppercase()` não existe; o certo é `.textCase(.uppercase)`.
- `$game.x` não funciona com `@Environment`. Use `Binding(get: { game.x }, set: { game.x = $0 })`.
- `.sheet(item:)` exige um tipo `Identifiable` (String não serve).
- Tipos `Color` e `View` exigem `import SwiftUI`.
- Nada de propriedade `@ViewBuilder let` em struct genérica chamada com um valor.
- Não use APIs de iOS 18+ (por exemplo `@Entry`, `.onScrollGeometryChange` e `MeshGradient` são 18+).
- CloudKit:
  - `CKRecord(recordType:recordID: CKRecord.ID(recordName:))`.
  - `try await db.records(matching:)` retorna uma tupla; use `.matchResults`.
  - `CKAccountStatus` não tem `.unknown`; o valor é `.couldNotDetermine`.
- GameKit: use o async/await moderno.
- Expressões longas encadeadas (filter/map com `||`) estouram o type-checker: quebre em variáveis com tipo explícito.
- Não declare um tipo com nome que já existe no projeto. Antes de criar `struct X`, rode Grep "struct X\b|class X\b|enum X\b" em Manna/. Se o nome já existir, use um prefixo da sua feature.
- `switch` em enum precisa ser exaustivo.
- Closures que capturam `self` em struct View não precisam de `[weak self]`.

## Escopo
- Só crie ou edite os arquivos que o seu pacote permite. Não crie stubs ou placeholders de telas de outros pacotes.
- Ao terminar, responda:
  - a lista de arquivos criados e editados;
  - onde ficam os pontos de entrada;
  - qualquer passo de configuração no App Store Connect ou no CloudKit.
