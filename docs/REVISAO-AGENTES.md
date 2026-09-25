# Revisão de funcionamento (agentes revisores)

O app compila, mas o código foi escrito sem ninguém rodar. Sua tarefa é revisar a pasta que é sua como se você estivesse usando o app de verdade, e CORRIGIR os bugs de funcionamento. Siga também docs/REGRAS-AGENTES.md: o código precisa continuar compilando, não rode git nem build, e só edite os arquivos que são seus.

## O que procurar
- **Crash:**
  - force unwrap (`!`) em algo que pode ser nil;
  - índice fora do intervalo;
  - `@Environment(X.self)` de um tipo que não está injetado (injetados: GameState, ContentStore, AchievementStore, AvatarStore, LeagueStore, GameCenterService);
  - `CKContainer.default()`;
  - divisão por zero.
- **Botão morto:** a ação está vazia, é só um TODO, ou abre uma sheet ou tela que nunca aparece.
- **Tela inacessível:** um View que ninguém chama. Confira com Grep se existe um ponto de entrada. Se não existir, conecte-o numa tela da SUA pasta; se o lugar certo estiver fora da sua pasta, relate.
- **Navegação:**
  - `NavigationLink` fora de uma `NavigationStack`: confira quem apresenta a tela; sheet e fullScreenCover NÃO herdam a NavigationStack;
  - sheet que não fecha;
  - dois `.sheet`/`.fullScreenCover` no mesmo View disputando estado.
- **Estado:**
  - valor que deveria ser salvo e não é;
  - `didSet { save() }` disparando dentro de `load()` e apagando dados (use a guarda `isLoading`);
  - efeito colateral dentro de `body` (dar XP, gravar dados etc. dentro de um ViewBuilder roda a cada redesenho);
  - XP dado duas vezes;
  - `onAppear` que repete ação cara.
- **Lógica errada:** contas, datas (fuso, semana começando na segunda), textos que contradizem o comportamento.
- **CloudKit:**
  - o predicado não pode ter OR nem CONTAINS; use BEGINSWITH, `==` ou `IN`;
  - use `upsert()` em vez de `save()` para registros com ID fixo;
  - trate erros silenciosamente;
  - só chame o serviço com o iCloud disponível.
- **Textos:** português do Brasil correto; nada de "TODO", "PACOTE X" ou "outro agente" visível ao usuário.

## Resposta final
Liste os bugs encontrados e corrigidos (arquivo:linha, um por linha) e o que ficou pendente fora da sua pasta.
