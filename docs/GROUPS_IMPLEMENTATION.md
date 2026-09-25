# Grupos Cooperativos - Implementação Completa

## Arquivos Criados

### Backend (CloudKit Service)
- **`Manna/Services/Cloud/GroupsService.swift`** (423 linhas)
  - `@Observable final class GroupsService` com métodos `async/await`
  - Operações: `createGroup()`, `joinGroup()`, `leaveGroup()`, `refresh()`, `sync(game:)`, `sendCheer()`
  - Detecção automática de preview mode (sem chamadas CloudKit em testes)
  - Schema CloudKit documentado no topo do arquivo

### Frontend (Componentes SwiftUI)
- **`Manna/Features/Groups/GroupsView.swift`** (195 linhas)
  - Vista principal integrada na aba Ligas
  - Estado vazio com ovelhinha + botões "Criar grupo" e "Entrar com código"
  - Lista de grupos com cards, progresso semanal e ovelhinhas de membros
  - Pull-to-refresh para sincronizar dados

- **`Manna/Features/Groups/CreateGroupSheet.swift`** (267 linhas)
  - Sheet modal para criar novo grupo
  - Formulário: nome + seleção de meta semanal (200/500/1000/2000 XP)
  - Sucesso: exibe código grande, botão compartilhar, aviso "não é possível mudar nome"
  - Som e haptics ao criar

- **`Manna/Features/Groups/JoinGroupSheet.swift`** (331 linhas)
  - Sheet modal para entrar com código
  - Campo estilizado de 6 caracteres (maiúsculas automáticas, sem 0/O/1/I)
  - Tratamento de erro amigável em pt-BR
  - Sucesso: mostra nome do grupo, meta, membros, sua contribuição atual

- **`Manna/Features/Groups/GroupDetailSheet.swift`** (486 linhas)
  - Detalhe completo do grupo: cabeçalho, barra de progresso grande, membros, mural
  - Barra de progresso com animação (atualiza em tempo real)
  - Contribuições ordenadas (ranking colaborativo, sem "perdedores")
  - Mural de incentivos (últimos 20, com timestamps "Xm atrás")
  - 5 botões prontos: "Bora estudar! 📖", "Orando por vocês 🙏", "Que bênção! 🙌", "Não desistam! 💪", "Amém! ✨"
  - Confete/selo quando meta é atingida: "Meta do grupo cumprida! 🎉"
  - Botões: copiar código, compartilhar, sair (com confirmação)
  - Pull-to-refresh

### Componentes Auxiliares (em GroupDetailSheet)
- `MemberContributionRow`: linha com nome, XP, ícone de pão (se houver), barra de progresso
- `CheerBubble`: bolinha de incentivo com nome, mensagem, timestamp
- `GroupCard` (em GroupsView): card compacto com nome, código, meta, progresso, ovelhinhas

## Schema CloudKit (Banco de Dados Público)

Criar no CloudKit Dashboard (`iCloud.app.manna.ios` public database):

### Record Type: `MannaGroup`
| Campo | Tipo | Indexado? | Notas |
|-------|------|-----------|-------|
| `name` | String | Não | Nome do grupo |
| `code` | String | **Sim** (query) | 6 letras/números, sem 0/O/1/I |
| `weeklyGoal` | Int64 | Não | Meta XP semanal |
| `createdBy` | String | Não | userRecordID.recordName do criador |
| `createdAt` | DateTime | Não | Data de criação |

**Índice obrigatório**: `code` (para queries por código)

### Record Type: `MannaMember`
| Campo | Tipo | Indexado? | Notas |
|-------|------|-----------|-------|
| `groupCode` | String | **Sim** (query) | Código do grupo |
| `memberId` | String | Não | userRecordID.recordName |
| `displayName` | String | Não | Nome exibido no grupo |
| `weekKey` | String | Não | Semana ISO "YYYY-Www" (ex: "2025-W01") |
| `weeklyXP` | Int64 | Não | XP da semana atual |
| `bread` | Int64 | Não | Sequência de pão do membro |
| `updatedAt` | DateTime | Não | Última sincronização |

**recordName**: Determinístico `"\(groupCode)-\(memberId)"` (upsert)
**Índice obrigatório**: `groupCode` (para listar membros de um grupo)

### Record Type: `MannaCheer`
| Campo | Tipo | Indexado? | Notas |
|-------|------|-----------|-------|
| `groupCode` | String | **Sim** (query) | Código do grupo |
| `memberId` | String | Não | userRecordID.recordName de quem enviou |
| `displayName` | String | Não | Nome de quem enviou |
| `message` | String | Não | Texto pré-definido de incentivo |
| `createdAt` | DateTime | **Sim** (sort) | Para ordenar por recente |

**recordName**: Auto-gerado pela CloudKit (UUID)
**Índices obrigatórios**: 
- `groupCode` (para listar cheers do grupo)
- `createdAt` (sortable: true, para order by descending)

## Integração com GameState

O `sync(game:)` é chamado automaticamente:
1. Ao abrir a `GroupsView`
2. No pull-to-refresh
3. Quando o usuário completa uma lição (recomendado chamar em `LessonView` → `completeLesson()`)

```swift
// Em LessonView ou MainTabView:
task {
    await GroupsService.shared.sync(game: game)
}
```

## Fluxos de Usuário

### 1. Criar Grupo (Novo Usuário)
1. GroupsView → "Criar grupo"
2. CreateGroupSheet: nome + meta
3. Servidor gera código 6-char + salva no CloudKit
4. Success: exibe código grande + botão compartilhar
5. Grupo adicionado a `myGroups` (local + CloudKit)

### 2. Entrar em Grupo
1. GroupsView → "Entrar com código"
2. JoinGroupSheet: campo de 6 chars
3. Query CloudKit por código
4. Criar membro (record type MannaMember) se sucesso
5. Success: mostra nome do grupo, meta, membros atuais

### 3. Sincronizar XP Semanal
- `sync(game: GameState)` busca a semana ISO atual
- Para cada grupo do usuário, upsert MannaMember com weeklyXP e bread atuais
- Recarrega dados via `refresh()`

### 4. Ver Detalhe do Grupo
- Tap em card → GroupDetailSheet
- Exibe barra de progresso (soma de todos os MannaMember da semana atual)
- Lista membros ordenados por weeklyXP (DESC)
- Botões para enviar cheers (limite sugerido: 5 predefinidos)
- Mural com últimos 20 cheers

## Contratos Estáveis (Não Alterar)

- `GroupsView` → sem parâmetros, sem NavigationStack próprio (já está dentro de uma tela)
- `GroupsService.shared.sync(game:)` → chame sempre que XP mudar
- `GroupsService.shared.refresh()` → recarrega dados da CloudKit
- Incentivos são sempre strings pré-definidas (sem texto livre do usuário)

## Riscos de Compilação

### 1. Tipos CloudKit async/await (iOS 17+)
- ✅ Testado: `CKContainer.userRecordID()`, `publicDB.records(matching:)`, `publicDB.save()`, `publicDB.deleteRecord()`
- Requer: iOS 17+ mínimo (conforme especificado no projeto)

### 2. Preview sem CloudKit
- ✅ Detecta `XCODE_RUNNING_FOR_PREVIEWS == "1"` automaticamente
- Todas as sheets/views têm previews que não chamam CloudKit

### 3. @Observable + @MainActor
- ✅ `GroupsService` é `@observable final class` com `@unchecked Sendable`
- Updates são feitos em `DispatchQueue.main.async` explicitamente quando necessário

### 4. UserDefaults para grupos locais
- ✅ Chave: `"manna.groups.v1"` (versionada)
- Armazena array de códigos de grupo (`[String]`)
- Sincronizado com CloudKit

### 5. Sem pacotes de terceiros
- ✅ Apenas APIs nativas: SwiftUI, CloudKit, Foundation, AVFoundation (para SoundFX já existente)

## TODO para Outra Fase

- [ ] **Permissões**: Adicionar criador do grupo como admin (poder expulsar membros, editar meta)
- [ ] **Notificações**: Quando alguém bate a meta do grupo, notificar todos com push
- [ ] **Histórico semanal**: Guardar MannaMember com weekKey antigo para ranking histórico
- [ ] **Badges de contribuição**: Quem foi top 1/2/3 na semana recebe badge visual
- [ ] **Auto-cleanup**: Deletar MannaMember com weekKey muito antigo (limpeza de dados)
- [ ] **Modo offline**: Guardar cache local de grupos, sincronizar quando volta online

## Testes Recomendados

1. **Preview Mocks**: Todos os arquivos têm `#Preview` com dados de exemplo
2. **Teste CloudKit Dashboard**: 
   - Criar manual um MannaGroup com código `TEST01`
   - Entrar com JoinGroupSheet
   - Verificar se MannaMember foi criado
3. **Teste sync(game:)**:
   - Completar uma lição
   - Chamar `sync(game:)` manualmente
   - Verificar se weeklyXP foi atualizado na CloudKit

## Notas Importantes

- **Sem texto livre de usuários** em mensagens de incentivo (pre-defined list only)
- **Codigo gerado sem 0/O/1/I** para evitar confusão
- **Semana ISO** (seg-dom) para consistência com `GameState.weeklyXP`
- **Ranking colaborativo** (sem perdedores) — apenas ordem decrescente de contribuição
- **Sem moderação pesada** — apenas 5 tipos de incentivo pré-definidos
