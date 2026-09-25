# Configuração na Apple (depois de criar a conta Apple Developer)

## 1. Identificadores (developer.apple.com → Certificates, IDs & Profiles)

**App ID:** `app.manna.ios`. Capabilities:
- Game Center
- iCloud: CloudKit + Key-value storage
- App Groups

**Widget ID:** `app.manna.ios.widget`. Capabilities:
- App Groups

**Contêineres:**
- App Group: `group.app.manna.ios`
- iCloud: `iCloud.app.manna.ios`

## 2. App Store Connect → Meu app

### Assinaturas
Grupo "Manna Plus":

| Produto | ID | Detalhes |
|---|---|---|
| Mensal | `app.manna.plus.monthly` | R$ 19,90 |
| Anual | `app.manna.plus.yearly` | R$ 119,90 + teste grátis de 7 dias |
| Família (anual) | `app.manna.plus.family.yearly` | Ativar **Compartilhamento Familiar** |

### Game Center (placares)
- `app.manna.weekly.xp`: XP da semana, com reinício semanal (recorrente).
- `app.manna.total.xp`: XP total.

## 3. CloudKit Dashboard (icloud.developer.apple.com)

Contêiner: `iCloud.app.manna.ios`, banco **Public**. Crie os Record Types abaixo. Os campos estão documentados no topo de `Manna/Services/Cloud/GroupsService.swift` e de `Manna/Services/Cloud/FriendsService.swift`.

| Record Type | Uso |
|---|---|
| MannaGroup, MannaMember, MannaCheer | Grupos |
| MannaProfile | Perfil público e busca por @usuário |
| MannaFollow | Seguir |
| MannaFeedEvent, MannaReaction | Mural |
| MannaNudge | Cutucar |
| MannaFriendStreak | Pão compartilhado |
| MannaDuoQuest | Missão em dupla |
| MannaReport | Denúncias |

**Índices:**
- Marque como **Queryable** todos os campos usados em buscas: `code`, `groupCode`, `username`, `followerId`, `followeeId`, `authorId`, `toId`, `eventId`, `userA`, `userB`.
- Marque como **Sortable** o campo `createdAt`.
- Marque como Queryable o `recordName` de cada tipo.

**Security Roles:**
- **MannaFriendStreak** e **MannaDuoQuest** são atualizados pelos dois amigos. Dê permissão **Write** ao papel **Authenticated**.
- **MannaMember** e **MannaGroup**: Authenticated → Create. Cada usuário edita só o próprio registro.

Ao final, faça o deploy do schema para **Production**.

## 4. Revisão da App Store
- Conteúdo com usuários (mural, @usuário) exige denunciar e bloquear. Os dois já existem no app.
- Textos bíblicos: conferir os direitos da tradução usada (`Manna/Content/FONTES.md`).
- Política de privacidade e URL de suporte. O e-mail de contato fica em `FeedbackView.swift`.
