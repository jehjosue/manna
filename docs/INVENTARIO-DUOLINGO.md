# Inventário Duolingo × Manna

Fonte: Gummble, app `duolingo-ios`: 160 fluxos e 1.103 telas. Os fluxos repetidos entre versões foram agrupados em 75 funcionalidades.

Legenda:
- ✅ existe
- 🔨 pacote a construir (A–E)
- ⛔ não se aplica, com o motivo

## Aprender

| Duolingo | Manna | Status |
|---|---|---|
| Home / trilha | HomeView (trilha em zigue-zague, unidades) | ✅ |
| Starting / Completing a lesson, first lesson | LessonView + 8 tipos de exercício + CelebrationFlowView | ✅ |
| Completing a legendary level | Nível lendário (LegendaryLevelNode) | ✅ |
| Unit guidebook | UnitGuideView | ✅ |
| Stories / Completing a story lesson | StoriesListView / StoryPlayerView | ✅ |
| Practice hub / Practice | PracticeHubView | ✅ |
| Mistakes | Revisar erros (PracticeHub) | ✅ + lista de erros 🔨B |
| Completing a rapid review lesson | Desafio relâmpago (ChallengeView) | ✅ |
| Course / Courses / Adding a course | CourseSwitcherSheet (5 jornadas) | ✅ |
| Removing / Deleting a course | Ocultar jornada | 🔨D |
| Sections / Section detail / Choosing a section | Seções da jornada (visão geral + detalhe) | 🔨B |
| Skipping a unit | Teste para pular unidade | 🔨B |
| Topic detail | Detalhe do tema da unidade | 🔨B |
| Words / Sorting words | "Meus versículos" (lista, ordenar, ouvir) | 🔨B |
| Score information / More about score | "Nível bíblico" (pontuação por jornada) | 🔨B |
| Completing a radio lesson | "Rádio Manna" (episódio em áudio + perguntas) | 🔨E |
| Roleplay / Starting a roleplay / Completing a roleplay lesson | "Conversa com personagem" (roteiro com escolhas e voz) | 🔨E |
| Video call / Completing a video call lesson | "Ligação com Béé" (conversa por voz roteirizada) | 🔨E |
| Explain my answer | "Entenda a resposta" (explicação ampliada + versículo) | 🔨E |
| Completing a game lesson / Playing a game | Minijogo bíblico | 🔨E |
| Music / Song lesson / practice songs (busca, filtro) | ⛔ curso de música (instrumento). Hinos ficam para uma próxima versão |
| Chess / Math / Adding a course (math) | ⛔ outros cursos, fora do escopo bíblico |

## Motivação e jogo

| Duolingo | Manna | Status |
|---|---|---|
| Hearts / Run out of hearts / Practicing to get a heart | Óleo da lamparina / OutOfOilSheet / prática devolve óleo | ✅ |
| Energy | ⛔ variação do sistema de corações (o Manna usa óleo) |
| Streak / Personal streak | Pão diário + BreadStreakScreen + StreakCalendarView + dia de descanso | ✅ |
| Friend streaks / Accept / Invite / Remove | Pão compartilhado com amigo | 🔨A |
| Quests / Claiming a reward | QuestsView + baús + desafio mensal | ✅ |
| Starting friends clash (missão com amigo) | Missão em dupla | 🔨A |
| Leaderboard | LeaguesView (7 divisões) | ✅ |
| Achievements / Achievement detail | AchievementsView / AchievementDetailView | ✅ |
| Share an achievement / Saving / Downloading an image | Cartão de conquista para compartilhar | 🔨C |
| Monthly badges | Galeria de insígnias mensais | 🔨C |
| Year in review / Share | "Retrospectiva do ano" | 🔨C |
| Shop | ShopView | ✅ |
| Purchasing a timer boost | "Mais tempo" para o desafio relâmpago | 🔨E |

## Social

| Duolingo | Manna | Status |
|---|---|---|
| Friends / Following a user / Searching users | Amigos: buscar por @usuário, seguir | 🔨A |
| User profile (de outra pessoa) | Perfil público | 🔨A |
| Feed / Reactions / Liking / Commenting on a post | Mural: conquistas dos amigos + reações | 🔨A |
| Nudging a friend / Sending a nudge | "Cutucar" com mensagem pronta | 🔨A |
| Reporting a user | Denunciar e bloquear (exigido pela App Store para conteúdo de usuários) | 🔨A |
| Copying a profile link | Compartilhar @usuário / código | 🔨A |
| Setting / Adding a status | Status com emoji no perfil | 🔨C |
| Duolingo for Schools | ⛔ os grupos (GroupsView) cumprem o papel para igrejas e células |

## Conta, perfil e configurações

| Duolingo | Manna | Status |
|---|---|---|
| Onboarding / Choosing a learning goal | OnboardingView (6 passos) | ✅ |
| Creating an avatar | AvatarEditorView | ✅ |
| Profile / Profile (settings) | ProfileView | ✅ |
| Editing profile / Completing a profile | Editar nome, @usuário, status, avatar + card "complete seu perfil" | 🔨C |
| Courses (profile / settings) | Jornadas no perfil | 🔨C |
| Creating a profile / Logging in / Logging out / Saved accounts | Progresso salvo no iCloud (sem senha) | 🔨D |
| Resetting / Changing password, Verifying phone | ⛔ sem conta com senha (login pelo iCloud/Apple) |
| Deleting an account | "Apagar meus dados" | 🔨D |
| Settings | SettingsView | ✅ + ampliar 🔨D |
| Customizing reminders / Turning off notifications | Lembretes (NotificationScheduler) + tela de notificações | 🔨D |
| Changing app icon | Ícones alternativos | 🔨D |
| Giving feedback / Reporting an issue | Enviar opinião / relatar problema | 🔨D |
| Widgets / Add a widget | MannaWidget + tutorial "adicionar widget" | ✅ + tutorial 🔨D |
| Live Activities / Dynamic Island | Atividade ao vivo "pão em risco" | 🔨D |
| No connection | Aviso "sem conexão" nas telas online | 🔨D |

## Assinatura

| Duolingo | Manna | Status |
|---|---|---|
| Super / Subscribing / Choose a plan | PaywallView (mensal/anual) | ✅ |
| Manage subscription | showManageSubscriptions | ✅ |
| Canceling a subscription | Pesquisa de motivo + oferta antes de cancelar | 🔨D |
| Super Family / Manage family plan / Inviting to family | Plano Família (Compartilhamento Familiar da Apple) | 🔨D |
| Subscribing to Max / Max Family | ⛔ nível com IA paga. Depende de chave de API, fica como decisão futura |
| Gift a Super | ⛔ a App Store não permite presentear compras dentro do app |

## Pacotes

- **A. Amigos e social:** FriendsService (CloudKit), amigos, busca, seguir, perfil público, mural com reações, cutucar, pão compartilhado, missão em dupla, denunciar/bloquear.
- **B. Trilha avançada:** seções, detalhe da seção, teste para pular unidade, detalhe do tema, Meus versículos, Nível bíblico, lista de erros.
- **C. Perfil e compartilhamento:** editar/completar perfil, @usuário, status, jornadas no perfil, retrospectiva, cartão de conquista, insígnias mensais.
- **D. Configurações e sistema:** notificações, ícones alternativos, opinião/problema, apagar dados, ocultar jornada, sincronizar no iCloud, sem conexão, atividade ao vivo, tutorial do widget, cancelamento e plano família.
- **E. Novos modos de estudo:** Rádio Manna, Conversa com personagem, Ligação com Béé, Entenda a resposta, minijogo, mais tempo no relâmpago.
