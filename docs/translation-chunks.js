// Divide e junta o conteúdo para tradução por partes.
//   node docs/translation-chunks.js split            → docs/i18n/chunks/<base>/<parte>.pt.json
//   node docs/translation-chunks.js merge <lang>     → Manna/Content/<base>.<lang>.json (só quando todas as partes existem)
// Jornadas: parte "head" (title/subtitle) + uma parte por unidade (u1..u4).
// historias.json: partes de 4 histórias. radio/conversas/ligacoes: arquivo inteiro numa parte.
const fs = require("fs"), path = require("path");
const root = path.join(__dirname, "..");
const content = path.join(root, "Manna", "Content");
const chunksDir = path.join(__dirname, "i18n", "chunks");
const [cmd, lang] = process.argv.slice(2);
const bases = fs.readdirSync(content).filter(f => /\.json$/.test(f) && f.split(".").length === 2);
const write = (p, obj) => { fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, JSON.stringify(obj, null, 2) + "\n"); };

function parts(base, data) {
  if (base.startsWith("jornada-")) {
    const { units, ...head } = data;
    return [["head", head], ...units.map((u, i) => [`u${i + 1}`, u])];
  }
  if (base === "historias.json") {
    const out = [];
    for (let i = 0; i < data.length; i += 4) out.push([`p${i / 4 + 1}`, data.slice(i, i + 4)]);
    return out;
  }
  return [["all", data]];
}

if (cmd === "split") {
  for (const base of bases) {
    const data = JSON.parse(fs.readFileSync(path.join(content, base), "utf8"));
    for (const [name, obj] of parts(base, data)) write(path.join(chunksDir, base.replace(/\.json$/, ""), `${name}.pt.json`), obj);
  }
  console.log("partes em", chunksDir);
} else if (cmd === "merge" && lang) {
  let missing = [];
  for (const base of bases) {
    const data = JSON.parse(fs.readFileSync(path.join(content, base), "utf8"));
    const dir = path.join(chunksDir, base.replace(/\.json$/, ""));
    const got = parts(base, data).map(([name]) => {
      const p = path.join(dir, `${name}.${lang}.json`);
      if (!fs.existsSync(p)) { missing.push(path.relative(root, p)); return null; }
      return [name, JSON.parse(fs.readFileSync(p, "utf8"))];
    });
    if (got.some(g => !g)) continue;
    let merged;
    if (base.startsWith("jornada-")) merged = { ...got[0][1], units: got.slice(1).map(g => g[1]) };
    else if (base === "historias.json") merged = got.flatMap(g => g[1]);
    else merged = got[0][1];
    write(path.join(content, base.replace(/\.json$/, `.${lang}.json`)), merged);
    console.log("ok", base.replace(/\.json$/, `.${lang}.json`));
  }
  if (missing.length) { console.log("faltam partes:\n" + missing.join("\n")); process.exit(1); }
} else {
  console.error("uso: split | merge <lang>"); process.exit(2);
}
