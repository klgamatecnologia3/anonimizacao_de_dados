// Atualiza a seção automatica do documento de riscos LGPD a partir dos JSONs gerados do banco.
// O script extrai todos os campos em docs/database/json, identifica quais nomes de campo
// já aparecem explicitamente no markdown (está em .gitignore) e lista, ao final do documento, os campos restantes.

// Foi usado uma vez, para auxiliar na escrita do documento, mas pode ser reusado futuramente para manter a seção atualizada, se forem feitas mudanças nos JSONs ou no documento.

const fs = require('node:fs');
const path = require('node:path');

const docsJsonDir = path.resolve('docs/database/json');
const targetDocPath = path.resolve('docs/lgpd-riscos-e-direcao-anonimizacao.md');
const startMarker = '<!-- AUTO:UNMENTIONED_FIELDS:START -->';
const endMarker = '<!-- AUTO:UNMENTIONED_FIELDS:END -->';

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(fullPath) : [fullPath];
  });
}

function loadAllFields() {
  const files = walk(docsJsonDir).filter((filePath) => filePath.endsWith('.json'));
  const fields = new Set();

  for (const filePath of files) {
    const parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    for (const column of parsed.columns ?? []) {
      if (column && typeof column.field === 'string' && column.field.trim()) {
        fields.add(column.field.trim());
      }
    }
  }

  return [...fields].sort((left, right) => left.localeCompare(right));
}

function extractMentionedTokens(markdown) {
  return new Set(
    [...markdown.matchAll(/`([^`\r\n]+)`/g)]
      .map((match) => match[1].trim())
      .filter(Boolean),
  );
}

function buildAppendix(unmentionedFields) {
  const lines = [];
  lines.push('## Campos restantes nao mencionados explicitamente');
  lines.push('');
  lines.push(`Total identificado via JSON e nao citado explicitamente no texto: ${unmentionedFields.length}`);
  lines.push('');
  lines.push('Lista automatica gerada a partir de `docs/database/json`:');
  lines.push('');

  for (const field of unmentionedFields) {
    lines.push(`- \`${field}\``);
  }

  lines.push('');
  return lines.join('\n');
}

function updateDocument() {
  const allFields = loadAllFields();
  const originalDoc = fs.readFileSync(targetDocPath, 'utf8');
  const baseDoc = originalDoc.includes(startMarker)
    ? originalDoc.split(startMarker)[0].trimEnd()
    : originalDoc.trimEnd();
  const mentionedTokens = extractMentionedTokens(baseDoc);
  const unmentionedFields = allFields.filter((field) => !mentionedTokens.has(field));
  const appendix = buildAppendix(unmentionedFields);
  const updatedDoc = `${baseDoc}\n\n${startMarker}\n${appendix}${endMarker}\n`;

  fs.writeFileSync(targetDocPath, updatedDoc, 'utf8');

  console.log(JSON.stringify({
    totalFields: allFields.length,
    mentionedFields: allFields.length - unmentionedFields.length,
    unmentionedFields: unmentionedFields.length,
  }, null, 2));
}

updateDocument();
