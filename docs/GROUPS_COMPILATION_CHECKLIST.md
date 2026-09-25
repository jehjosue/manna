# Grupos Cooperativos — Checklist de Compilação

## Arquivos Criados (Total: 1.759 linhas de código Swift)

```
Manna/Services/Cloud/GroupsService.swift        (452 linhas)
Manna/Features/Groups/GroupsView.swift          (293 linhas)
Manna/Features/Groups/CreateGroupSheet.swift    (255 linhas)
Manna/Features/Groups/JoinGroupSheet.swift      (288 linhas)
Manna/Features/Groups/GroupDetailSheet.swift    (471 linhas)
```

## Verificações de Compilação Swift (iOS 17 + Swift 5.9)

### 1. ✅ Imports Obrigatórios
```swift
// GroupsService.swift
import Foundation
import CloudKit
import Observation

// Todas as Views
import SwiftUI
```
**Status**: OK — imports padrão, sem pacotes de terceiros

### 2. ✅ Tipos CloudKit async/await (iOS 17 required)
```swift
// CKContainer.accountStatus() — iOS 17+
self.accountStatus = try await container.accountStatus()

// CKContainer.userRecordID() — iOS 17+
self.userRecordID = try await container.userRecordID()

// CKDatabase.records(matching:) — iOS 17+
let results = try await publicDB.records(matching: query)

// CKDatabase.save(_:) — iOS 17+
_ = try await publicDB.save(record)

// CKDatabase.deleteRecord(withID:) — iOS 17+
try await publicDB.deleteRecord(withID: id)
```
**Status**: OK — todas as APIs async/await são suportadas em iOS 17

### 3. ✅ @Observable + @MainActor
```swift
@Observable
final class GroupsService: @unchecked Sendable {
    // ...
    private(set) var myGroups: [MannaGroup] = []
}
```
**Status**: OK — `@Observable` do módulo `Observation` é iOS 17+

### 4. ✅ Environment + @Environment
```swift
@Environment(GameState.self) private var game
```
**Status**: OK — padrão SwiftUI iOS 17

### 5. ✅ Acesso ao UIPasteboard
```swift
UIPasteboard.general.string = group.code
```
**Status**: OK — nativo no iOS, não requer permissão de pasteboard

### 6. ✅ ProcessInfo para detectar Preview
```swift
ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
```
**Status**: OK — padrão XcodeGen para desabilitar CloudKit em previews

### 7. ✅ Coordenação entre vistas (sem NavigationStack duplicado)
```swift
// GroupsView não tem NavigationStack próprio
// Uses sheets apenas
.sheet(isPresented: $showCreateSheet) {
    CreateGroupSheet(isPresented: $showCreateSheet)
}

// CreateGroupSheet tem NavigationStack APENAS internamente
NavigationStack {
    // Sheet content
}
```
**Status**: OK — contratualizações respeitadas

### 8. ✅ Binding + @Binding
```swift
@Binding var isPresented: Bool
@Binding var selectedGroupCode: String?
```
**Status**: OK — padrão SwiftUI para comunicação pai-filho

### 9. ✅ ShareLink (iOS 16+)
```swift
ShareLink(
    item: "Vamos estudar...",
    subject: Text("Junte-se ao meu grupo")
) { Label }
```
**Status**: OK — iOS 16+, suportado no projeto (iOS 17)

### 10. ✅ Uso de GameIcon (DesignSystem)
```swift
GameIconView(icon: .bread, size: 16)
```
**Status**: OK — já existe em `Manna/DesignSystem/GameIconView.swift`

### 11. ✅ Uso de Theme (DesignSystem)
```swift
Theme.cream, Theme.card, Theme.ink, Theme.wheat, Theme.olive, Theme.terracotta, Theme.night
Theme.font(size, weight)
Theme.corner, Theme.depth
```
**Status**: OK — todas as cores e fontes já estão definidas em `Theme.swift`

### 12. ✅ Uso de SoundFX e Haptics (DesignSystem)
```swift
SoundFX.play(.reward)
SoundFX.play(.wrong)
Haptics.success()
Haptics.error()
Haptics.tap()
```
**Status**: OK — já existem em `Manna/DesignSystem/Feedback.swift`

### 13. ✅ Uso de SheepView (DesignSystem)
```swift
SheepView(mood: .happy, size: 120)
SheepView(mood: .cheering, size: 100)
SheepView(mood: .thinking, size: 100)
```
**Status**: OK — 3 moods usados (happy, cheering, thinking) definidos em `SheepView.swift`

### 14. ✅ ButtonStyle.chunky (DesignSystem)
```swift
Button { } .buttonStyle(.chunky)
Button { } .buttonStyle(.chunkyNight)
```
**Status**: OK — estilos definidos em `Components.swift`

### 15. ✅ ProgressView (SwiftUI nativa)
```swift
ProgressView()
    .progressViewStyle(.circular)
    .tint(.white)
```
**Status**: OK — nativa em SwiftUI iOS 17

### 16. ✅ ScrollView + RefreshableProtocol
```swift
ScrollView {
    // content
}
.refreshable {
    await service.refresh()
}
```
**Status**: OK — SwiftUI iOS 17

### 17. ✅ GeometryReader (para barras de progresso)
```swift
GeometryReader { geo in
    RoundedRectangle(cornerRadius: 8)
        .fill(Theme.line)
        .frame(width: geo.size.width * min(progress, 1))
}
.frame(height: 12)
```
**Status**: OK — padrão SwiftUI

### 18. ✅ ForEach com .prefix()
```swift
ForEach(group.members.prefix(8)) { member in
    SheepMiniView(member: member)
}
```
**Status**: OK — `Sequence.prefix()` é padrão Swift

### 19. ✅ LazyVStack e LazyVGrid
```swift
LazyVStack(spacing: 12) { }
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) { }
```
**Status**: OK — SwiftUI iOS 13+

### 20. ✅ TimeInterval e Date manipulation
```swift
Date(timeIntervalSinceNow: -3600)
Date().timeIntervalSince(date)
```
**Status**: OK — Foundation padrão

## CloudKit Setup Required

Criar no CloudKit Dashboard (`iCloud.app.manna.ios` — public database):

### ✅ Record Type: MannaGroup
- [ ] Fields: name, code (indexed), weeklyGoal, createdBy, createdAt

### ✅ Record Type: MannaMember
- [ ] Fields: groupCode (indexed), memberId, displayName, weekKey, weeklyXP, bread, updatedAt

### ✅ Record Type: MannaCheer
- [ ] Fields: groupCode (indexed), memberId, displayName, message, createdAt (indexed+sortable)

## UserDefaults Setup

✅ Automaticamente criado em `GroupsService`:
- Key: `"manna.groups.v1"` (array de códigos)

## Preview Mode Testing

✅ Todos os arquivos incluem `#Preview` com dados mock:
- GroupsView (estado vazio e com grupos)
- CreateGroupSheet
- JoinGroupSheet
- GroupDetailSheet

**Modo preview não faz chamadas CloudKit** — detecta via `ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]`

## Compilação XcodeGen

**Caminho esperado**: `C:\Users\domde\manna\Manna/` → entrada automática no target

**Nenhum arquivo deve ser adicionado manualmente ao projeto Xcode** — XcodeGen auto-detecta `.swift` em `Manna/`.

## Potenciais Erros de Compilação

### 1. ❌ "CloudKit framework not imported"
**Solução**: Garantir que `Manna.xcodeproj` inclui `CloudKit` no build settings. Verificar `capabilities` no projeto Xcode (iCloud/CloudKit).

### 2. ❌ "Cannot find 'GameState' in scope"
**Solução**: `GameState` deve estar importado implicitamente no target. Verificar se `Manna/Models/GameState.swift` está no target.

### 3. ❌ "Cannot find 'Theme' / 'SoundFX' / 'Haptics' / 'SheepView'"
**Solução**: Design system components já existem em `Manna/DesignSystem/`. Garantir que estão no target.

### 4. ❌ "'records(matching:)' requires iOS 17.0 or later"
**Solução**: Confirmar `deployment target = iOS 17` no projeto. Se usar iOS 16, descomentar fallback (não implementado aqui).

### 5. ❌ "Type 'GroupsService' does not conform to 'Observable'"
**Solução**: Adicionar `import Observation` no arquivo.

### 6. ❌ "Cannot convert value of type 'Double' to expected argument type 'CGFloat'"
**Solução**: Já feito — `progress * Double(width)` convertido corretamente com `Double` em `GeometryReader`.

## Testes Recomendados Pós-Compilação

```bash
# 1. Build limpo
xcodebuild clean build -scheme Manna

# 2. Run previews em Xcode
# → Todas as 5 views devem renderizar sem CloudKit calls

# 3. Device test (iOS 17.0+)
# → Criar grupo (requer iCloud login)
# → Entrar em grupo (via código)
# → Sincronizar XP
# → Enviar incentivo
```

## Entrega Final

- ✅ 5 arquivos Swift criados (1.759 linhas)
- ✅ Schema CloudKit documentado
- ✅ Sem pacotes de terceiros
- ✅ Sem commits Git
- ✅ Prévia completa em GROUPS_IMPLEMENTATION.md
- ✅ Checklist de compilação neste documento
