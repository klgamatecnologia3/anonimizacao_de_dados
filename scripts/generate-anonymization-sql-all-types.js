// Gera um script SQL independente de anonimização para homologação.
// Esta versão organiza a decisão primeiro por tipo SQL e depois refina por nome de coluna.
// Regras principais:
// - preserva datas em geral, exceto datas pessoais evidentes como nascimento;
// - preserva somente public.clientes.id = 1;
// - não altera IDs e colunas booleanas;
// - gera valores compatíveis com tipo, tamanho médio amostrado e restrições usuais.
//
// IMPORTANTE:
// Se quiser desabilitar a anonimização de colunas json/jsonb, troque para false.
// O script continuará funcionando normalmente; essas colunas apenas serão ignoradas.

const fs = require('node:fs/promises');
const path = require('node:path');
const { Client } = require('pg');
require('dotenv').config({ path: '.env.script' });

const TARGET_SCHEMA = process.env.DB_SCHEMA || 'public';
const OUTPUT_SQL_PATH = path.resolve(process.env.ANON_SQL_OUTPUT || 'sql/anonymize-homologation-all-types.sql');
const SAMPLE_SIZE = Number(process.env.ANON_SAMPLE_SIZE || 20);
const ENABLE_JSON_ANONYMIZATION = true;

function parseBoolean(value, fallback) {
  if (value === undefined) return fallback;
  return String(value).toLowerCase() === 'true';
}

function buildClientConfigFromEnv() {
  if (process.env.DATABASE_URL) {
    return { connectionString: process.env.DATABASE_URL };
  }

  const host = process.env.DB_HOST;
  const port = process.env.DB_PORT ? Number(process.env.DB_PORT) : 5432;
  const database = process.env.DB_NAME;
  const user = process.env.DB_USER;
  const password = process.env.DB_PASSWORD;
  const sslEnabled = parseBoolean(process.env.DB_SSL, true);

  if (!host || !database || !user || !password) {
    throw new Error(
      'Defina DATABASE_URL ou as variaveis DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD e DB_SSL no .env.script.',
    );
  }

  return {
    host,
    port,
    database,
    user,
    password,
    ssl: sslEnabled ? { rejectUnauthorized: false } : false,
  };
}

function quoteIdentifier(identifier) {
  return `"${String(identifier).replace(/"/g, '""')}"`;
}

function quoteLiteral(value) {
  return `'${String(value).replace(/'/g, "''")}'`;
}

function normalizeName(name) {
  return String(name || '').toLowerCase();
}

function stripLength(typeName) {
  return String(typeName || '').replace(/\(.+\)$/, '').toLowerCase();
}

function coalesceNumber(value, fallback) {
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

function inferLength(meta) {
  const charLength = Number(meta.character_maximum_length || 0);
  return charLength > 0 ? charLength : null;
}

function castSuffix(meta) {
  const dataType = stripLength(meta.data_type);

  if (dataType === 'uuid') return '::uuid';
  if (dataType === 'json') return '::json';
  if (dataType === 'jsonb') return '::jsonb';
  if (dataType === 'date') return '::date';
  if (dataType.includes('timestamp')) return `::${dataType}`;
  if (dataType === 'text') return '::text';
  if (dataType === 'character varying') return '::varchar';
  if (dataType === 'character') return '::char';
  if (dataType === 'bpchar') return '::bpchar';
  if (dataType === 'bytea') return '::bytea';
  return '';
}

function buildRepeatedTextExpression(seedText, targetLength, castType) {
  const safeLength = Math.max(targetLength, seedText.length);
  const literal = quoteLiteral(seedText);
  return `left(repeat(${literal}, ceil(${safeLength}::numeric / length(${literal}))::int), ${safeLength})${castType}`;
}

function buildPrefixedTextExpression(prefix, targetLength, castType) {
  const safeLength = Math.max(targetLength, prefix.length + 4);
  return `left(${quoteLiteral(prefix)} || lpad(src.anon_seq::text, greatest(${safeLength} - length(${quoteLiteral(prefix)}), 1), '0'), ${safeLength})${castType}`;
}

function buildDigitExpression(length, castType, offset = 0) {
  const safeLength = Math.max(length, 4);
  return `left(lpad((((src.anon_seq + ${offset}) * 1111111)::bigint)::text, ${safeLength}, substr('1234567890', ((src.anon_seq + ${offset}) % 10) + 1, 1)), ${safeLength})${castType}`;
}

function buildEmailExpression(targetLength, castType) {
  const safeLength = Math.max(targetLength, 18);
  return `left('alfredo.' || src.anon_seq::text || '@example.com', ${safeLength})${castType}`;
}

function buildPhoneExpression(length, castType) {
  const safeLength = Math.max(length, 10);
  return `left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, ${safeLength} - 2, '0'), ${safeLength})${castType}`;
}

function buildDateExpression(columnName, castType) {
  const name = normalizeName(columnName);
  if (name.includes('nasc')) {
    return `((date '1985-01-01' + ((src.anon_seq % 12000) * interval '1 day'))::date)${castType}`;
  }
  return `((date '2024-01-01' + ((src.anon_seq % 365) * interval '1 day'))::date)${castType}`;
}

function buildTimestampExpression(castType) {
  return `((timestamp '2024-01-01 08:00:00' + ((src.anon_seq % 365) * interval '1 day') + ((src.anon_seq % 600) * interval '1 minute')))${castType}`;
}

function buildNumericExpression(meta, castType) {
  const precision = meta.numeric_precision;
  const scale = meta.numeric_scale ?? 0;

  if (scale > 0) {
    const maxIntegerDigits = Math.max((precision || 12) - scale, 1);
    const maxInteger = Math.min(10 ** Math.min(maxIntegerDigits, 9) - 1, 999999999);
    return `((((src.anon_seq * 37) % ${maxInteger || 999999999})::numeric) + ((src.anon_seq % 100)::numeric / ${10 ** scale}))${castType}`;
  }

  const maxValue = precision ? Math.min(10 ** Math.min(precision, 9) - 1, 999999999) : 999999999;
  return `(((src.anon_seq * 37) % ${maxValue || 999999999}) + 1)${castType}`;
}

function buildIntegerExpression(meta, castType) {
  const bits = Number(meta.numeric_precision || 32);
  const maxValue = bits >= 63 ? '9223372036854775807' : String(Math.min((2 ** Math.min(bits - 1, 30)) - 1, 2147483647));
  return `(((src.anon_seq * 37) % ${maxValue}) + 1)${castType}`;
}

function buildJsonExpression(meta) {
  const payload = {
    anon: true,
    origem: 'script_sql_all_types',
    valor: 'dados anonimizados',
  };
  return `${quoteLiteral(JSON.stringify(payload))}::${stripLength(meta.udt_name || meta.data_type)}`;
}

function buildUuidExpression(castType) {
  return `(md5('anon-' || src.anon_seq::text || '-uuid') || '-' || substr(md5('anon-b' || src.anon_seq::text), 1, 4) || '-4' || substr(md5('anon-c' || src.anon_seq::text), 1, 3) || '-a' || substr(md5('anon-d' || src.anon_seq::text), 1, 3) || '-' || substr(md5('anon-e' || src.anon_seq::text), 1, 12))::uuid${castType === '::uuid' ? '' : castType}`;
}

function buildFileExpression(targetLength, castType) {
  const safeLength = Math.max(targetLength, 16);
  return `left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), ${safeLength})${castType}`;
}

function buildUrlExpression(targetLength, castType) {
  const safeLength = Math.max(targetLength, 24);
  return `left('https://example.com/anon/' || src.anon_seq::text, ${safeLength})${castType}`;
}

function buildPathExpression(targetLength, castType) {
  const safeLength = Math.max(targetLength, 20);
  return `left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), ${safeLength})${castType}`;
}

function buildByteaExpression(meta) {
  if (meta.is_nullable === 'YES') {
    return 'NULL';
  }
  return `decode('00', 'hex')`;
}

function isBooleanLike(meta) {
  return stripLength(meta.data_type) === 'boolean';
}

function isBytea(meta) {
  return stripLength(meta.data_type) === 'bytea';
}

function isDateLike(meta) {
  const type = stripLength(meta.data_type);
  return type === 'date' || type.includes('timestamp');
}

function isNumericLike(meta) {
  const type = stripLength(meta.data_type);
  return ['smallint', 'integer', 'bigint', 'numeric', 'decimal', 'real', 'double precision'].includes(type);
}

function isTextualLike(meta) {
  const type = stripLength(meta.data_type);
  return ['text', 'character varying', 'character', 'bpchar'].includes(type);
}

function isJsonLike(meta) {
  const type = stripLength(meta.data_type);
  return type === 'json' || type === 'jsonb';
}

function refineTextStrategy(meta) {
  const name = normalizeName(meta.column_name);
  const length = inferLength(meta);
  const avgLength = coalesceNumber(meta.sample_avg_length, length || 24);
  const targetLength = length ? Math.min(Math.max(avgLength, 6), length) : Math.max(avgLength, 12);
  const castType = castSuffix(meta);

  if (name.includes('email') || name === 'user') {
    return { category: 'email', expression: buildEmailExpression(targetLength, castType) };
  }
  if (name.includes('cpf') || name.includes('cnpj')) {
    const digits = avgLength >= 14 ? 14 : 11;
    return { category: 'documento', expression: buildDigitExpression(digits, castType, 3) };
  }
  if (name.includes('telefone') || name.includes('celular') || name.includes('whatsapp') || name === 'wpp') {
    return { category: 'telefone', expression: buildPhoneExpression(targetLength, castType) };
  }
  if (name.includes('senha') || name.includes('token') || name.includes('codigo') || name.includes('codigotemporario')) {
    return { category: 'credencial', expression: buildPrefixedTextExpression('anon_', targetLength, castType) };
  }
  if (name.includes('arquivo')) {
    return { category: 'arquivo', expression: buildFileExpression(targetLength, castType) };
  }
  if (name.includes('link') || name === 'url' || name.startsWith('url')) {
    return { category: 'url', expression: buildUrlExpression(targetLength, castType) };
  }
  if (name.includes('path') || name.includes('caminho')) {
    return { category: 'path', expression: buildPathExpression(targetLength, castType) };
  }
  if (name.includes('nome') || name.includes('razao') || name.includes('fantasia') || name.includes('usuario') || name.includes('responsavel') || name.includes('motorista') || name.includes('destinador') || name.includes('transportadora') || name.includes('gerador')) {
    return { category: 'nome', expression: buildPrefixedTextExpression('anonimo_', targetLength, castType) };
  }
  if (name.includes('endereco') || name.includes('bairro') || name.includes('municipio') || name.includes('complemento') || name.includes('logradouro')) {
    return { category: 'endereco', expression: buildPrefixedTextExpression('dados anonimizados ', targetLength, castType) };
  }
  if (name.includes('cep')) {
    return { category: 'cep', expression: buildDigitExpression(8, castType, 7) };
  }
  if (name.includes('placa')) {
    return { category: 'placa', expression: buildPrefixedTextExpression('ABC', Math.max(targetLength, 7), castType) };
  }
  if (name.includes('obs') || name.includes('coment') || name.includes('descricao') || name.includes('resumo') || name.includes('texto') || name.includes('servico') || name.includes('servicos')) {
    return {
      category: 'texto_livre',
      expression: buildRepeatedTextExpression('dados anonimizados - ', targetLength, castType),
    };
  }
  return { category: 'texto_generico', expression: buildPrefixedTextExpression('anon_', targetLength, castType) };
}

function resolveStrategy(meta) {
  const name = normalizeName(meta.column_name);
  const dataType = stripLength(meta.data_type);
  const castType = castSuffix(meta);

  if (name === 'id' || name.startsWith('id')) return null;
  if (isBooleanLike(meta)) return null;

  if (isBytea(meta)) {
    return { category: 'bytea', expression: buildByteaExpression(meta) };
  }

  if (isJsonLike(meta)) {
    // IMPORTANTE:
    // Este bloco controla a anonimização de json/jsonb com um payload sintético padrão.
    // Se você não quiser mexer em json/jsonb por enquanto, deixe ENABLE_JSON_ANONYMIZATION = false
    // no topo do arquivo. O restante do script continuará gerando SQL normalmente.
    if (!ENABLE_JSON_ANONYMIZATION) {
      return null;
    }
    return { category: 'json', expression: buildJsonExpression(meta) };
  }

  if (isDateLike(meta)) {
    if (name.includes('nasc')) {
      return {
        category: 'data_pessoal',
        expression: dataType === 'date' ? buildDateExpression(meta.column_name, castType) : buildTimestampExpression(castType),
      };
    }
    return null;
  }

  if (dataType === 'uuid') {
    return { category: 'uuid', expression: buildUuidExpression(castType) };
  }

  if (isNumericLike(meta)) {
    if (['smallint', 'integer', 'bigint'].includes(dataType)) {
      return { category: 'numerico_inteiro', expression: buildIntegerExpression(meta, castType) };
    }
    return { category: 'numerico', expression: buildNumericExpression(meta, castType) };
  }

  if (isTextualLike(meta)) {
    return refineTextStrategy(meta);
  }

  return null;
}

function getExclusionPredicate(tableName, availableColumns) {
  const columns = new Set(availableColumns.map((column) => column.column_name));
  if (normalizeName(tableName) === 'clientes' && columns.has('ID')) {
    return `coalesce(${quoteIdentifier('ID')}::int, -1) <> 1`;
  }
  return 'true';
}

async function getBaseTables(client) {
  const query = `
    select table_name
    from information_schema.tables
    where table_schema = $1
      and table_type = 'BASE TABLE'
    order by table_name;
  `;
  const { rows } = await client.query(query, [TARGET_SCHEMA]);
  return rows.map((row) => row.table_name);
}

async function getColumns(client, tableName) {
  const query = `
    select
      column_name,
      data_type,
      udt_name,
      is_nullable,
      character_maximum_length,
      numeric_precision,
      numeric_scale
    from information_schema.columns
    where table_schema = $1
      and table_name = $2
    order by ordinal_position;
  `;
  const { rows } = await client.query(query, [TARGET_SCHEMA, tableName]);
  return rows;
}

async function getSampleStats(client, tableName, columnName) {
  const query = `
    with sample as (
      select length(${quoteIdentifier(columnName)}::text) as len
      from ${quoteIdentifier(TARGET_SCHEMA)}.${quoteIdentifier(tableName)}
      where ${quoteIdentifier(columnName)} is not null
      limit ${SAMPLE_SIZE}
    )
    select
      coalesce(ceil(avg(len)), 0)::int as avg_length,
      coalesce(max(len), 0)::int as max_length,
      count(*)::int as sample_count
    from sample;
  `;
  const { rows } = await client.query(query);
  return rows[0];
}

function buildUpdateSql(tableName, columns) {
  const assignments = columns.map((column) => `      ${quoteIdentifier(column.column_name)} = ${column.strategy.expression}`).join(',\n');
  const exclusionPredicate = getExclusionPredicate(tableName, columns);

  return `-- ${tableName}
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from ${quoteIdentifier(TARGET_SCHEMA)}.${quoteIdentifier(tableName)}
  where ${exclusionPredicate}
),
updated as (
  update ${quoteIdentifier(TARGET_SCHEMA)}.${quoteIdentifier(tableName)} as tgt
  set
${assignments}
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select ${quoteLiteral(tableName)} as table_name, count(*) as affected_rows from updated;
`;
}

function buildHeader(strategySummary) {
  const generatedAt = new Date().toISOString();
  return [
    '-- Script SQL independente de anonimização gerado automaticamente.',
    `-- Schema alvo: ${TARGET_SCHEMA}`,
    `-- Gerado em: ${generatedAt}`,
    '-- Regras principais:',
    '-- - primeiro decide pelo tipo SQL, depois refina por nome da coluna quando necessário;',
    '-- - usa amostra de até 20 valores por coluna para estimar comprimento;',
    '-- - não altera IDs e colunas booleanas;',
    '-- - preserva datas em geral; anonimiza apenas datas pessoais evidentes;',
    '-- - define bytea como NULL quando a coluna aceita nulo, ou binário mínimo quando NOT NULL;',
    '-- - preserva apenas o registro ID = 1 da tabela clientes.',
    '',
    'begin;',
    '',
    '-- Resumo por categoria identificada',
    ...strategySummary.map(([category, count]) => `-- ${category}: ${count}`),
    '',
  ].join('\n');
}

async function main() {
  const client = new Client(buildClientConfigFromEnv());
  await client.connect();

  try {
    const tables = await getBaseTables(client);
    const tableStatements = [];
    const strategyCounts = new Map();

    for (const tableName of tables) {
      const columns = await getColumns(client, tableName);
      const anonymizable = [];

      for (const column of columns) {
        const sample = await getSampleStats(client, tableName, column.column_name);
        const enriched = {
          ...column,
          sample_avg_length: sample.avg_length,
          sample_max_length: sample.max_length,
          sample_count: sample.sample_count,
        };
        const strategy = resolveStrategy(enriched);
        if (!strategy) continue;

        anonymizable.push({
          ...enriched,
          strategy,
        });
        strategyCounts.set(strategy.category, (strategyCounts.get(strategy.category) || 0) + 1);
      }

      if (anonymizable.length === 0) continue;
      tableStatements.push(buildUpdateSql(tableName, anonymizable));
    }

    const summary = [...strategyCounts.entries()].sort((a, b) => a[0].localeCompare(b[0]));
    const sql = `${buildHeader(summary)}${tableStatements.join('\n')}\ncommit;\n`;

    await fs.mkdir(path.dirname(OUTPUT_SQL_PATH), { recursive: true });
    await fs.writeFile(OUTPUT_SQL_PATH, sql, 'utf8');

    console.log(`Arquivo gerado: ${OUTPUT_SQL_PATH}`);
    console.log(`Tabelas com UPDATE: ${tableStatements.length}`);
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error('Erro ao gerar SQL de anonimização independente:', error.message);
  process.exit(1);
});
