// Gera, do zero, um script SQL de anonimização para homologação.
// Regras desta versão:
// - preserva somente public.clientes.id = 1;
// - não altera IDs nem colunas booleanas;
// - preserva datas em geral e anonimiza datas pessoais evidentes, como nascimento;
// - decide primeiro pelo tipo SQL e refina por nome quando o tipo é genérico;
// - usa amostra de até 20 valores por coluna para estimar comprimento médio;
// - gera um arquivo SQL executável com UPDATEs por tabela.
//
// IMPORTANTE:
// Se quiser ignorar json/jsonb, troque a flag abaixo para false.
// O script continuará funcionando e apenas pulará essas colunas.

const fs = require('node:fs/promises');
const path = require('node:path');
const { Client } = require('pg');
require('dotenv').config({ path: '.env.script' });

const TARGET_SCHEMA = process.env.DB_SCHEMA || 'public';
const OUTPUT_SQL_PATH = path.resolve(process.env.ZERO_ANON_SQL_OUTPUT || 'sql/zero-full-anonymization.sql');
const SAMPLE_SIZE = Number(process.env.ZERO_ANON_SAMPLE_SIZE || 20);
const ENABLE_JSON_ANONYMIZATION = true;

// IMPORTANTE:
// false = apenas gera o arquivo SQL em disco para você executar depois.
// true = executa diretamente no banco e não gera o arquivo SQL.
// Mantenha false enquanto estiver validando a estratégia de anonimização.
const EXECUTE_DIRECTLY_IN_DATABASE = false;

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

function normalizedType(meta) {
  return String(meta.data_type || '').toLowerCase();
}

function charLength(meta) {
  const value = Number(meta.character_maximum_length || 0);
  return value > 0 ? value : null;
}

function meanLength(meta, fallback = 24) {
  const sampled = Number(meta.sample_avg_length || 0);
  if (sampled > 0) return sampled;
  const max = charLength(meta);
  if (max) return Math.min(max, fallback);
  return fallback;
}

function targetTextLength(meta, minimum = 8, fallback = 24) {
  const average = meanLength(meta, fallback);
  const max = charLength(meta);
  if (!max) return Math.max(average, minimum);
  return Math.min(Math.max(average, minimum), max);
}

function withCast(expression, meta) {
  const type = normalizedType(meta);
  if (type === 'text') return `${expression}::text`;
  if (type === 'character varying') return `${expression}::varchar`;
  if (type === 'character') return `${expression}::char`;
  if (type === 'date') return `${expression}::date`;
  if (type.includes('timestamp')) return `${expression}::${type}`;
  if (type === 'uuid') return `${expression}::uuid`;
  return expression;
}

function repeatText(seed, length, meta) {
  const literal = quoteLiteral(seed);
  const safeLength = Math.max(length, seed.length);
  return withCast(`left(repeat(${literal}, ceil(${safeLength}::numeric / length(${literal}))::int), ${safeLength})`, meta);
}

function prefixedSequence(prefix, length, meta) {
  const safeLength = Math.max(length, prefix.length + 4);
  const prefixLiteral = quoteLiteral(prefix);
  return withCast(
    `left(${prefixLiteral} || lpad(src.anon_seq::text, greatest(${safeLength} - length(${prefixLiteral}), 1), '0'), ${safeLength})`,
    meta,
  );
}

function emailExpression(meta) {
  return withCast(`left('alfredo.' || src.anon_seq::text || '@example.com', ${targetTextLength(meta, 18, 32)})`, meta);
}

function digitExpression(length, meta, multiplier = 1111111) {
  const safeLength = Math.max(length, 4);
  return withCast(
    `left(lpad(((src.anon_seq * ${multiplier})::bigint)::text, ${safeLength}, substr('1234567890', (src.anon_seq % 10) + 1, 1)), ${safeLength})`,
    meta,
  );
}

function phoneExpression(meta) {
  const length = targetTextLength(meta, 10, 14);
  return withCast(
    `left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, ${Math.max(length - 2, 8)}, '0'), ${length})`,
    meta,
  );
}

function urlExpression(meta) {
  return withCast(`left('https://example.com/anon/' || src.anon_seq::text, ${targetTextLength(meta, 24, 48)})`, meta);
}

function pathExpression(meta) {
  return withCast(`left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), ${targetTextLength(meta, 20, 40)})`, meta);
}

function fileExpression(meta) {
  return withCast(`left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), ${targetTextLength(meta, 16, 32)})`, meta);
}

function genericNameExpression(meta) {
  return prefixedSequence('anonimo_', targetTextLength(meta, 10, 30), meta);
}

function genericAddressExpression(meta) {
  return repeatText('dados anonimizados - ', targetTextLength(meta, 16, 40), meta);
}

function genericTextExpression(meta) {
  return prefixedSequence('anon_', targetTextLength(meta, 8, 24), meta);
}

function freeTextExpression(meta) {
  return repeatText('dados anonimizados - ', targetTextLength(meta, 18, 80), meta);
}

function uuidExpression() {
  return `(md5('anon-' || src.anon_seq::text || '-uuid') || '-' || substr(md5('anon-b' || src.anon_seq::text), 1, 4) || '-4' || substr(md5('anon-c' || src.anon_seq::text), 1, 3) || '-a' || substr(md5('anon-d' || src.anon_seq::text), 1, 3) || '-' || substr(md5('anon-e' || src.anon_seq::text), 1, 12))::uuid`;
}

function numericExpression(meta) {
  const precision = Number(meta.numeric_precision || 12);
  const scale = Number(meta.numeric_scale || 0);

  if (scale > 0) {
    const integerDigits = Math.max(precision - scale, 1);
    const integerLimit = Math.min(10 ** Math.min(integerDigits, 9) - 1, 999999999);
    return `((((src.anon_seq * 37) % ${integerLimit || 999999999})::numeric) + ((src.anon_seq % 100)::numeric / ${10 ** scale}))::numeric`;
  }

  const maxValue = Math.min(10 ** Math.min(precision, 9) - 1, 999999999);
  return `(((src.anon_seq * 37) % ${maxValue || 999999999}) + 1)`;
}

function integerExpression(meta) {
  const type = normalizedType(meta);
  if (type === 'smallint') return `(((src.anon_seq * 17) % 32000) + 1)`;
  if (type === 'bigint') return `(((src.anon_seq * 37)::bigint % 9223372036854775806) + 1)`;
  return `(((src.anon_seq * 37) % 2147483646) + 1)`;
}

function byteaExpression(meta) {
  if (meta.is_nullable === 'YES') return 'NULL';
  return `decode('00', 'hex')`;
}

function jsonExpression(meta) {
  const payload = {
    anon: true,
    origem: 'zero-script',
    valor: 'dados anonimizados',
  };
  return `${quoteLiteral(JSON.stringify(payload))}::${normalizedType(meta)}`;
}

function personalDateExpression(meta) {
  const type = normalizedType(meta);
  if (type === 'date') {
    return `((date '1985-01-01' + ((src.anon_seq % 12000) * interval '1 day'))::date)`;
  }
  return `((timestamp '1985-01-01 09:00:00' + ((src.anon_seq % 12000) * interval '1 day')))::${type}`;
}

function classifyTextByName(meta) {
  const name = normalizeName(meta.column_name);

  if (name.includes('email') || name === 'user') {
    return { category: 'email', expression: emailExpression(meta) };
  }
  if (name.includes('cpf') || name.includes('cnpj')) {
    const sample = meanLength(meta, 14);
    return { category: 'documento', expression: digitExpression(sample >= 14 ? 14 : 11, meta) };
  }
  if (name.includes('telefone') || name.includes('celular') || name.includes('whatsapp') || name === 'wpp') {
    return { category: 'telefone', expression: phoneExpression(meta) };
  }
  if (name.includes('senha') || name.includes('token') || name.includes('codigo') || name.includes('codigotemporario')) {
    return { category: 'credencial', expression: prefixedSequence('anon_', targetTextLength(meta, 8, 20), meta) };
  }
  if (name.includes('arquivo')) {
    return { category: 'arquivo', expression: fileExpression(meta) };
  }
  if (name.includes('link') || name === 'url' || name.startsWith('url')) {
    return { category: 'url', expression: urlExpression(meta) };
  }
  if (name.includes('path') || name.includes('caminho')) {
    return { category: 'path', expression: pathExpression(meta) };
  }
  if (name.includes('nome') || name.includes('razao') || name.includes('fantasia') || name.includes('usuario') || name.includes('responsavel') || name.includes('motorista') || name.includes('destinador') || name.includes('transportadora') || name.includes('gerador')) {
    return { category: 'nome', expression: genericNameExpression(meta) };
  }
  if (name.includes('endereco') || name.includes('bairro') || name.includes('municipio') || name.includes('logradouro') || name.includes('complemento')) {
    return { category: 'endereco', expression: genericAddressExpression(meta) };
  }
  if (name.includes('cep')) {
    return { category: 'cep', expression: digitExpression(8, meta, 7777777) };
  }
  if (name.includes('placa')) {
    return { category: 'placa', expression: prefixedSequence('ABC', targetTextLength(meta, 7, 8), meta) };
  }
  if (name.includes('obs') || name.includes('coment') || name.includes('descricao') || name.includes('resumo') || name.includes('texto') || name.includes('servico') || name.includes('servicos')) {
    return { category: 'texto_livre', expression: freeTextExpression(meta) };
  }
  return { category: 'texto_generico', expression: genericTextExpression(meta) };
}

function resolveStrategy(meta) {
  const name = normalizeName(meta.column_name);
  const type = normalizedType(meta);

  if (name === 'id' || name.startsWith('id')) return null;
  if (type === 'boolean') return null;

  if (type === 'date' || type.includes('timestamp')) {
    if (name.includes('nasc')) {
      return { category: 'data_pessoal', expression: personalDateExpression(meta) };
    }
    return null;
  }

  if (type === 'uuid') {
    return { category: 'uuid', expression: uuidExpression() };
  }

  if (type === 'json' || type === 'jsonb') {
    if (!ENABLE_JSON_ANONYMIZATION) return null;
    return { category: 'json', expression: jsonExpression(meta) };
  }

  if (type === 'bytea') {
    return { category: 'bytea', expression: byteaExpression(meta) };
  }

  if (type === 'smallint' || type === 'integer' || type === 'bigint') {
    return { category: 'numerico_inteiro', expression: integerExpression(meta) };
  }

  if (['numeric', 'decimal', 'real', 'double precision'].includes(type)) {
    return { category: 'numerico', expression: numericExpression(meta) };
  }

  if (['text', 'character varying', 'character'].includes(type)) {
    return classifyTextByName(meta);
  }

  return null;
}

function exclusionPredicate(tableName, columns) {
  const hasId = columns.some((column) => column.column_name === 'ID');
  if (normalizeName(tableName) === 'clientes' && hasId) {
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
  const assignments = columns
    .map((column) => `      ${quoteIdentifier(column.column_name)} = ${column.strategy.expression}`)
    .join(',\n');

  return `-- ${tableName}
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from ${quoteIdentifier(TARGET_SCHEMA)}.${quoteIdentifier(tableName)}
  where ${exclusionPredicate(tableName, columns)}
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

function buildHeader(summary) {
  const generatedAt = new Date().toISOString();
  return [
    '-- Script SQL de anonimização gerado do zero.',
    `-- Schema alvo: ${TARGET_SCHEMA}`,
    `-- Gerado em: ${generatedAt}`,
    '-- Regras principais:',
    '-- - preserva apenas public.clientes.id = 1;',
    '-- - não altera IDs e colunas booleanas;',
    '-- - preserva datas em geral e anonimiza datas pessoais evidentes;',
    '-- - decide primeiro pelo tipo SQL e depois pelo nome da coluna;',
    '-- - usa média amostral de até 20 linhas por coluna.',
    '',
    'begin;',
    '',
    '-- Resumo por categoria',
    ...summary.map(([category, count]) => `-- ${category}: ${count}`),
    '',
  ].join('\n');
}

async function main() {
  const client = new Client(buildClientConfigFromEnv());
  await client.connect();

  try {
    const tables = await getBaseTables(client);
    const statements = [];
    const categoryCount = new Map();

    for (const tableName of tables) {
      const columns = await getColumns(client, tableName);
      const planned = [];

      for (const column of columns) {
        const sample = await getSampleStats(client, tableName, column.column_name);
        const meta = {
          ...column,
          sample_avg_length: sample.avg_length,
          sample_max_length: sample.max_length,
          sample_count: sample.sample_count,
        };
        const strategy = resolveStrategy(meta);

        if (!strategy) continue;

        planned.push({ ...meta, strategy });
        categoryCount.set(strategy.category, (categoryCount.get(strategy.category) || 0) + 1);
      }

      if (planned.length > 0) {
        statements.push(buildUpdateSql(tableName, planned));
      }
    }

    const summary = [...categoryCount.entries()].sort((a, b) => a[0].localeCompare(b[0]));
    const sql = `${buildHeader(summary)}${statements.join('\n')}\ncommit;\n`;

    if (EXECUTE_DIRECTLY_IN_DATABASE) {
      await client.query(sql);
      console.log('SQL executado diretamente no banco.');
      console.log(`Tabelas com UPDATE: ${statements.length}`);
      return;
    }

    await fs.mkdir(path.dirname(OUTPUT_SQL_PATH), { recursive: true });
    await fs.writeFile(OUTPUT_SQL_PATH, sql, 'utf8');

    console.log(`Arquivo gerado: ${OUTPUT_SQL_PATH}`);
    console.log(`Tabelas com UPDATE: ${statements.length}`);
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error('Erro ao gerar SQL de anonimização zero:', error.message);
  process.exit(1);
});
