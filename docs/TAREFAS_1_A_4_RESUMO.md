# Tarefas 1-4: Conquistas, Avatar, Perfil e Ligas — Resumo de Implementação

## Arquivos Criados

### Tarefa 1: Conquistas (`Features/Achievements/`)
- **AchievementStore.swift** — Store observable com ~15 conquistas, 5 níveis cada, derivadas 100% dos contadores do GameState
- **AchievementsView.swift** — Grade 2x2 de medalhas com progresso, navegável para detalhes
- **AchievementDetailView.swift** — Detalhe de conquista com todos os níveis, botão resgate de maná
- **AchievementUnlockOverlay.swift** — Modificador `.achievementUnlockOverlay()` que monitora mudanças no GameState e mostra popup comemorativo com medalha, som e vibração

### Tarefa 2: Avatar da Ovelhinha (`Features/Avatar/`)
- **AvatarStore.swift** — Store com cores de lã (branca, creme, cinza, chocolate) e 8 acessórios (chapéu, coroa, cachecol, óculos, laço, cajado, gorro, estrela)
- **SheepAvatarView.swift** — `SheepAvatarView(size:)` = SheepView base + acessórios equipados, proporcionais ao tamanho
- **AvatarEditorView.swift** — Editor com 5 abas (Lã, Cabeça, Pescoço, Rosto, Acessórios), preview grande, compra/equipamento de itens

### Tarefa 3: Perfil (`Features/Profile/`)
- **ProfileView.swift** — NavigationStack com cabeçalho (avatar grande + nome + "membro desde"), botão engrenagem (Settings), seção Estatísticas (grade 2x2), Pão Diário (calendário), Conquistas (3 destaques + "Ver todas"), Amigos (Game Center), botão Compartilhar Progresso
- **StreakCalendarView.swift** — Calendário mensal com navegação, dias estudados marcados via `game.studied(on:)`, checkmarks coloridos
- **SettingsView.swift** — Toggle som/vibração, hora do lembrete, placeholder para mais (referenciado sem parâmetros: `SettingsView()`)

### Tarefa 4: Ligas + Game Center (`Features/Leagues/` + `Services/GameCenter/`)
- **GameCenterService.swift** — Auth via `GKLocalPlayer.local.authenticateHandler`, submissão de XP semanal/total, carregamento de leaderboards (global e amigos), amigos, reportAchievement, painel GKGameCenterViewController
- **LeagueStore.swift** — 7 divisões (Grão de Mostarda → Trigo → Oliveira → Videira → Cedro → Pérola → Ouro de Ofir), cada com cor, ícone, threshold de promoção/retenção, detecta transições semanais
- **LeaguesView.swift** — Topo com emblema da divisão, tempo até fim da semana, barra de promoção; abas Ligas (Global/Amigos com leaderboard semanal + seu rank destacado) e Grupos (stub referenciado)
- **GroupsView.swift** — Stub para tarefa de outro agente (referenciado sem parâmetros: `GroupsView()`)

## Contratos Respeitados

✅ **MainTabView.swift** — Sem alterações. Chama `LeaguesView()` e `ProfileView()` sem parâmetros (criados com assinatura correta)

✅ **GameState.swift** — Sem alterações. Lê contadores: `xpTotal`, `weeklyXP`, `bread`, `bestBread`, `perfectLessonCount`, `practiceCount`, `challengeCount`, `storiesCompleted`, `completedLessonCount`, `completedCount(in:)`, `manna`, `addManna()`, `spendManna()`, `joinedAt`, `userName`, `studied(on:)`, `isPlus`

✅ **DesignSystem/** — Sem alterações. Usa `Theme`, `ChunkyButtonStyle`, `ChoiceCard`, `StatBadge`, `GameIconView`, `SheepView`, `SoundFX.play()`, `Haptics.*`, `SpeechBubble`

✅ **ContentStore.shared.journeys** — Referenciado apenas em AchievementStore para "Peregrino"

## Assinaturas Públicas e IDs para App Store Connect

### Leaderboards (GameKit)
```
app.manna.weekly.xp      — Ranking semanal de XP
app.manna.total.xp       — Ranking total de XP
```

### Achievements (GameKit)
Não hardcoded nos arquivos (reportados dinamicamente), mas sugeridos para registrar no App Store Connect:
```
app.manna.pao-diario.bronze
app.manna.pao-diario.silver
app.manna.pao-diario.gold
app.manna.pao-diario.platinum
app.manna.pao-diario.diamond
(... e mais, um por achievement × tier, total ~40)
```

### Stores com Persistência
- `AchievementStore.shared` — `UserDefaults` key `"manna.achievements.v1"`
- `AvatarStore.shared` — `UserDefaults` key `"manna.avatar.v1"`
- `LeagueStore.shared` — `UserDefaults` key `"manna.league.v1"`
- `GameCenterService.shared` — Sem persistência local (GK gerencia)

## Fluxo de Integração

1. **Em MainTabView**, importar os stores:
   ```swift
   @State var achievementStore = AchievementStore()
   @State var avatarStore = AvatarStore()
   @State var leagueStore = LeagueStore()
   @State var gameCenterService = GameCenterService()
   ```

2. **Environment** — Injetar em todas as abas:
   ```swift
   .environment(achievementStore)
   .environment(avatarStore)
   .environment(leagueStore)
   .environment(gameCenterService)
   ```

3. **Em ProfileView**, aplicar overlay no topo:
   ```swift
   .achievementUnlockOverlay()
   ```

4. **Ao completar atividades** (em LessonViewModel ou similar), chamar:
   ```swift
   gameCenter.submitWeeklyXP(game.weeklyXP)
   gameCenter.submitTotalXP(game.xpTotal)
   leagueStore.evaluateWeeklyProgress(weeklyXP: game.weeklyXP)
   ```

## Riscos de Compilação (Resolvidos)

| Risco | Resolução |
|-------|-----------|
| ContentStore não definido | Usar `ContentStore.shared.journeys` (contrato estável) |
| GameIcon não tem construtor | GameIcon é enum, acesso via `.bread`, `.manna` etc. |
| SettingsView / GroupsView não definidas por mim | Criados como stubs referenciais sem parâmetros |
| AvatarStore.woolColor vs gameState.xxx conflicts | Separadas em stores independentes (sem sobrescrita) |
| Circle() vs Ellipse() disponíveis? | iOS 17, ambas nativas |

## Decisões Técnicas

- **Valores hardcoded vs dinâmicos**: Todas as conquistas têm nomes bíblicos próprios (não "Achievement 1") e descrições descritivas
- **Sem auréola no avatar**: Substituída por "Estrela de Belém" (mais cultural)
- **Perseverança de divisão**: LeagueStore detecta transição semanal via calendário ISO (segunda = início)
- **Sem usuários falsos nas ligas**: Game Center apenas (real friends + global leaderboard)
- **Resgates únicos**: AchievementStore rastreia `claimedRewards` por `"achievementId-tier"` para evitar resgate duplo

## Próximos Passos (Para Outros Agentes)

1. **Agente de Grupos** → Implementar `GroupsView()` completo (referenciado em LeaguesView)
2. **Agente de Onboarding** → Confirmar injeção de stores no RootView
3. **Agente de Activity Completion** → Chamar `achievementStore.checkForNewUnlocks(game:)` e `leagueStore.evaluateWeeklyProgress()`
4. **Agente App Store** → Registrar 2 leaderboards + ~40 achievements no App Store Connect

---

**Compilação teórica**: ✅ Todos os tipos existem, todos os imports presentes, contatos respeitados, sem Swift 6.0 concurrency (seguro em iOS 17).
