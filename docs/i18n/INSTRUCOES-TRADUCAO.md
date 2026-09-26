# Como traduzir uma parte do conteúdo do Manna

Projeto: C:\Users\domde\manna. As partes em português ficam em `docs/i18n/chunks/<base>/<parte>.pt.json`.
Para cada parte que você recebeu:

1. Leia `<parte>.pt.json` com a ferramenta Read.
2. Escreva a tradução em `<parte>.<lang>.json`, na mesma pasta, com a ferramenta Write. Traduza **você mesmo, texto por texto**. NÃO use script, regex ou dicionário automático para traduzir: isso já estragou traduções antes.
3. Faça uma parte de cada vez: leia, escreva e passe para a próxima.

## Regras
- **Estrutura idêntica:** mesmas chaves, mesma ordem e mesmo número de itens em cada lista.
- **Não se traduz:** `id`, `kind`, `icon`, `order`, `isTrue`.
- **Tudo o que o usuário vê é traduzido:** title, subtitle, summary, keyVerses (reference e text), prompt, speaker, text, reference, options, answer, tokens, distractors, pairs (left e right), statement, explanation, falas, perguntas e palavras-chave de reconhecimento de fala.
- **Bíblia:** em inglês, use a World English Bible (WEB); em espanhol, a Reina-Valera 1909. Nas referências, escreva os nomes dos livros no idioma de destino (João → John / Juan). Nomes bíblicos também vão na forma do idioma.
- **Consistência dentro de cada exercício:**
  - `answer` deve ser idêntico a um item de `options`;
  - buildVerse: `tokens` em ordem formam o versículo, e nenhum `distractors` pode ser igual a um token;
  - typeAnswer: `text` tem exatamente um `___`, e `answer` preenche a lacuna;
  - matchPairs: lefts diferentes entre si e rights diferentes entre si;
  - orderEvents: tokens sem repetição.
- **Personagens do app:** Béé, Paz, Tito, Judá, Mirela, Tobias, Ana e Noemi mantêm o nome. Vovó Ester vira "Grandma Ester" / "Abuela Ester"; Pastor Davi, "Pastor David"; Tio Samuel, "Uncle Samuel" / "Tío Samuel"; Narrador, "Narrator" / "Narrador".

## Conferência (obrigatória no final)
- `node docs/translation-chunks.js merge <lang>` monta os arquivos completos. É normal ele listar partes que faltam e que são de outros agentes.
- `node docs/check-translation.js <lang> <base>.json` para cada base sua. Tem que terminar com "TRADUÇÃO OK". Se reclamar de algo, corrija a SUA parte e rode de novo.
- Para as jornadas: copie o `<base>.<lang>.json` gerado para uma pasta temporária com o nome sem o idioma e rode `node docs/validate-content.js <pasta>`. Tem que dar "SEM ERROS".

Não edite arquivos Swift. Não rode git.
