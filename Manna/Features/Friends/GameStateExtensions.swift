import Foundation

// MARK: - Extensão do GameState para publicação de eventos sociais

/// Extensão do GameState que providencia funções para publicar eventos
/// no mural de amigos (conquistas, pão compartilhado, etc).
extension GameState {

    /// Publica uma conquista desbloqueada no mural.
    /// Chamado quando o usuário desbloqueia uma nova achievement.
    /// Exemplo: `game.publishAchievementEvent(title: "Primeira Semana", description: "...").`
    func publishAchievementEvent(title: String, description: String) async {
        let text = "\(title): \(description)"
        _ = await FriendsService.shared.postEvent(kind: "achievement", text: text)
    }

    /// Publica um milestone de pão (sequência) no mural.
    /// Chamado quando a sequência atinge um número redondo (7 dias, 30 dias, etc).
    /// Exemplo: `game.publishBreadMilestoneEvent(days: 7, bestBread: game.bestBread).`
    func publishBreadMilestoneEvent(days: Int) async {
        guard days > 0 && days % 7 == 0 else { return }  // Publicar a cada 7 dias
        let text = "Mantém a sequência por \(days) dias! 🔥"
        _ = await FriendsService.shared.postEvent(kind: "bread", text: text)
    }

    /// Publica quando o usuário avança uma jornada (curso).
    /// Chamado quando completa uma seção ou atinge um marco.
    /// Exemplo: `game.publishJourneyProgressEvent(journeyName: "Gênesis")`.
    func publishJourneyProgressEvent(journeyName: String) async {
        let text = "Avançou em '\(journeyName)'! 📖"
        _ = await FriendsService.shared.postEvent(kind: "journey", text: text)
    }

    /// Publica quando o usuário sobe de liga.
    /// Chamado quando weeklyXP ultrapassa threshold de liga.
    /// Exemplo: `game.publishLeaguePromotionEvent(fromLeague: "Bronze", toLeague: "Prata")`.
    func publishLeaguePromotionEvent(fromLeague: String, toLeague: String) async {
        let text = "Subiu de liga! \(fromLeague) → \(toLeague) 🏅"
        _ = await FriendsService.shared.postEvent(kind: "league", text: text)
    }

    /// Atualiza o perfil público do usuário na CloudKit.
    /// Chamado periodicamente de MannaApp.syncOnline() para sincronizar
    /// xpTotal, weeklyXP, bread, e avatar.
    /// Requer que ProfileIdentityStore.shared.username esteja preenchido.
    func syncProfileToCloud(avatar: String? = nil, status: String? = nil) async {
        let profile = ProfileIdentityStore.shared
        guard !profile.username.isEmpty else { return }

        await FriendsService.shared.publishMyProfile(
            username: profile.username,
            displayName: profile.displayName.isEmpty ? userName : profile.displayName,
            game: self,
            avatar: avatar,
            status: status
        )
    }

    /// Incrementa XP de uma missão em dupla (se existe uma ativa).
    /// Chamado quando o usuário completa uma lição/desafio.
    /// Exemplo: `game.updateDuoQuestProgress(xpGained: 50)`.
    func updateDuoQuestProgress(xpGained: Int) async {
        // Nota: isso requer carregar o DuoQuest, incrementar seu XP,
        // e salvar de volta. Por simplicidade, fica para o PACOTE A v2.
        // Agora, apenas incrementar o xpTotal normal.
    }
}
