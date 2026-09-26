// Confere traduções de conteúdo: node docs/check-translation.js <lang> [arquivo-base.json ...]
// Para cada Manna/Content/<base>.json compara com <base>.<lang>.json:
//  - mesma estrutura (chaves, ids, kinds, tamanhos de arrays, isTrue)
//  - textos traduzidos (sinaliza strings idênticas ao português ou com palavras típicas do português)
const fs = require("fs"), path = require("path");
const dir = path.join(__dirname, "..", "Manna", "Content");
const lang = process.argv[2];
if (!lang) { console.error("uso: node check-translation.js <en|es|...> [base.json...]"); process.exit(2); }
const bases = process.argv.slice(3).length ? process.argv.slice(3)
  : fs.readdirSync(dir).filter(f => /\.json$/.test(f) && f.split(".").length === 2);

// Campos que NÃO se traduzem
const KEEP = new Set(["id", "kind", "icon", "order", "isTrue", "answerIndex", "correctIndex", "character", "speakerId", "mood"]);
const PT = /ção|ções|ã|õ|(^|[^\p{L}])(não|você|vocês|também|então|nós|nosso|nossa|pelo|pela|Deus|Senhor|disse|foi|muito|já|isso|quem|qual|ele|ela|uma|seu|sua)(?=$|[^\p{L}])/iu;
const NAMES = /^(Béé|Paz|Tito|Judá|Mirela|Tobias|Ana|Noemi|Noemí|Jesus|Jesús|Maria|María|Deus)$/;

let problems = 0;
const report = (f, msg) => { problems++; if (problems <= 400) console.log(`${f}: ${msg}`); };

function walk(a, b, p, f) {
  if (Array.isArray(a)) {
    if (!Array.isArray(b)) return report(f, `${p}: esperado array`);
    if (a.length !== b.length) report(f, `${p}: ${a.length} itens no original, ${b.length} na tradução`);
    for (let i = 0; i < Math.min(a.length, b.length); i++) walk(a[i], b[i], `${p}[${i}]`, f);
    return;
  }
  if (a && typeof a === "object") {
    if (!b || typeof b !== "object") return report(f, `${p}: esperado objeto`);
    for (const k of Object.keys(a)) {
      if (!(k in b)) { report(f, `${p}.${k}: faltando`); continue; }
      if (KEEP.has(k)) { if (JSON.stringify(a[k]) !== JSON.stringify(b[k])) report(f, `${p}.${k}: valor alterado`); continue; }
      walk(a[k], b[k], `${p}.${k}`, f);
    }
    for (const k of Object.keys(b)) if (!(k in a)) report(f, `${p}.${k}: chave extra`);
    return;
  }
  if (typeof a === "string") {
    if (typeof b !== "string") return report(f, `${p}: esperado texto`);
    const t = b.trim();
    if (t.length > 3 && !NAMES.test(t) && !/^[\d\s:.,;–-]+$/.test(t)) {
      if (t === a.trim() && PT.test(t)) report(f, `${p}: não traduzido → "${t.slice(0, 60)}"`);
      else if (lang !== "pt" && PT.test(t) && !/^[A-Z][a-zà-ú]+ \d/.test(t) ) report(f, `${p}: parece português → "${t.slice(0, 60)}"`);
    }
  }
}

for (const base of bases) {
  const src = path.join(dir, base), dst = path.join(dir, base.replace(/\.json$/, `.${lang}.json`));
  if (!fs.existsSync(dst)) { report(base, `FALTA ${path.basename(dst)}`); continue; }
  let a, b;
  try { a = JSON.parse(fs.readFileSync(src, "utf8")); b = JSON.parse(fs.readFileSync(dst, "utf8")); }
  catch (e) { report(base, `JSON inválido: ${e.message}`); continue; }
  walk(a, b, "$", path.basename(dst));
}
console.log(problems ? `\n${problems} PROBLEMAS` : "TRADUÇÃO OK");
process.exit(problems ? 1 : 0);
