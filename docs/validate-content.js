// Valida todo o conteúdo do Manna contra o modelo Swift.
const fs = require("fs"), path = require("path");
const dir = process.argv[2];
const icons = new Set(["star.fill","book.fill","sparkles","person.2.fill","heart.fill","leaf.fill","drop.fill","flame.fill","sun.max.fill","moon.stars.fill","hands.sparkles.fill","crown.fill","fish.fill","water.waves","cross.fill","mountain.2.fill","house.fill","gift.fill","music.note","shield.fill","tree.fill","bird.fill","tent.fill","scroll.fill","key.fill","lightbulb.fill"]);
const K = {
  journey: ["id","title","subtitle","icon","order","units"],
  unit: ["id","title","subtitle","lessons","guide"],
  guide: ["summary","keyVerses"], verse: ["reference","text"],
  lesson: ["id","title","icon","exercises"],
  ex: ["id","kind","prompt","speaker","text","reference","options","answer","tokens","distractors","pairs","statement","isTrue","explanation"],
  story: ["id","title","subtitle","icon","reference","steps"],
  step: ["kind","speaker","text","options","answer"],
};
const errs = [], ids = new Map(), kinds = {};
const E = (w, m) => errs.push(`${w}: ${m}`);
const keys = (o, k, w) => Object.keys(o).forEach(x => { if (!K[k].includes(x)) E(w, `chave inválida "${x}"`); });
const str = (v) => typeof v === "string" && v.trim().length > 0;
const uid = (id, w) => { if (!str(id)) return E(w, "id vazio"); if (ids.has(id)) E(w, `id duplicado ${id} (também em ${ids.get(id)})`); ids.set(id, w); };

for (const f of fs.readdirSync(dir).filter(f => /^jornada-.*\.json$/.test(f))) {
  let j; try { j = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")); } catch (e) { E(f, "JSON inválido " + e.message); continue; }
  keys(j, "journey", f); uid(j.id, f);
  ["id","title","subtitle","icon"].forEach(k => str(j[k]) || E(f, `journey.${k} ausente`));
  if (!icons.has(j.icon)) E(f, `ícone da jornada ${j.icon}`);
  if (typeof j.order !== "number") E(f, "order ausente");
  if (j.units.length !== 4) E(f, `${j.units.length} unidades`);
  for (const u of j.units) {
    const wu = `${f}/${u.id}`; keys(u, "unit", wu); uid(u.id, wu);
    ["title","subtitle"].forEach(k => str(u[k]) || E(wu, `${k} ausente`));
    if (!u.guide) E(wu, "sem guide"); else { keys(u.guide, "guide", wu); str(u.guide.summary) || E(wu, "guide sem summary"); (u.guide.keyVerses || []).forEach(v => { keys(v, "verse", wu); str(v.reference) && str(v.text) || E(wu, "keyVerse incompleto"); }); if (!(u.guide.keyVerses || []).length) E(wu, "guide sem versos"); }
    if (u.lessons.length !== 5) E(wu, `${u.lessons.length} lições`);
    for (const l of u.lessons) {
      const wl = `${f}/${l.id}`; keys(l, "lesson", wl); uid(l.id, wl);
      if (!icons.has(l.icon)) E(wl, `ícone ${l.icon}`);
      if (l.exercises.length !== 8) E(wl, `${l.exercises.length} exercícios`);
      for (const e of l.exercises) {
        const we = `${f}/${e.id}`; keys(e, "ex", we); uid(e.id, we);
        kinds[e.kind] = (kinds[e.kind] || 0) + 1;
        if (!str(e.prompt)) E(we, "sem prompt");
        const opts = e.options || [];
        const uniq = (a) => new Set(a).size === a.length;
        switch (e.kind) {
          case "multipleChoice": case "listen":
            if (opts.length < 2 || opts.length > 4) E(we, `${opts.length} opções`);
            if (!uniq(opts)) E(we, "opções repetidas");
            if (!opts.includes(e.answer)) E(we, "answer fora das options");
            if (e.kind === "listen" && !str(e.text)) E(we, "listen sem text");
            break;
          case "buildVerse":
            if (!Array.isArray(e.tokens) || e.tokens.length < 3) E(we, "tokens insuficientes");
            if (!str(e.reference)) E(we, "sem reference");
            (e.distractors || []).forEach(d => { if ((e.tokens || []).includes(d)) E(we, `distrator igual a bloco: ${d}`); });
            break;
          case "matchPairs": {
            const p = e.pairs || [];
            if (p.length !== 4) E(we, `${p.length} pares`);
            if (!uniq(p.map(x => x.left)) || !uniq(p.map(x => x.right))) E(we, "pares repetidos");
            p.forEach(x => { if (!str(x.left) || !str(x.right)) E(we, "par vazio"); });
            break; }
          case "trueFalse":
            if (!str(e.statement) || typeof e.isTrue !== "boolean") E(we, "trueFalse incompleto");
            break;
          case "typeAnswer":
            if (!str(e.text) || (e.text.match(/___/g) || []).length !== 1) E(we, "text precisa de exatamente um ___");
            if (!str(e.answer)) E(we, "sem answer");
            break;
          case "orderEvents":
            if (!Array.isArray(e.tokens) || e.tokens.length < 3 || e.tokens.length > 5) E(we, "orderEvents precisa de 3–5 tokens");
            else if (!uniq(e.tokens)) E(we, "tokens repetidos");
            break;
          case "speak":
            if (!str(e.text) || !str(e.reference)) E(we, "speak sem text/reference");
            break;
          default: E(we, `kind inválido ${e.kind}`);
        }
      }
    }
  }
}

const hf = path.join(dir, "historias.json");
if (fs.existsSync(hf)) {
  let s; try { s = JSON.parse(fs.readFileSync(hf, "utf8")); } catch (e) { E("historias", "JSON inválido"); s = []; }
  for (const st of s) {
    const w = `historias/${st.id}`; keys(st, "story", w); uid(st.id, w);
    if (!icons.has(st.icon)) E(w, `ícone ${st.icon}`);
    ["title","subtitle","reference"].forEach(k => str(st[k]) || E(w, `${k} ausente`));
    for (const p of st.steps) {
      keys(p, "step", w);
      if (!["line","question"].includes(p.kind)) E(w, `step kind ${p.kind}`);
      if (!str(p.text)) E(w, "step sem text");
      if (p.kind === "question" && !(p.options || []).includes(p.answer)) E(w, "pergunta com answer fora das options");
    }
  }
  console.log("histórias:", s.length);
}
console.log("tipos:", kinds);
console.log(errs.length ? `${errs.length} ERROS:\n` + errs.join("\n") : "SEM ERROS");
