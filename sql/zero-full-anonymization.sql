-- Script SQL de anonimização gerado do zero.
-- Schema alvo: public
-- Gerado em: 2026-03-12T17:54:02.339Z
-- Regras principais:
-- - preserva apenas public.clientes.id = 1;
-- - não altera IDs e colunas booleanas;
-- - preserva datas em geral e anonimiza datas pessoais evidentes;
-- - define colunas jsonb[] (udt_name = _jsonb) como NULL quando permitido;
-- - decide primeiro pelo tipo SQL e depois pelo nome da coluna;
-- - usa média amostral de até 20 linhas por coluna.

begin;

-- Resumo por categoria
-- arquivo: 9
-- cep: 3
-- credencial: 10
-- data_pessoal: 1
-- documento: 10
-- email: 10
-- endereco: 14
-- jsonb_array: 5
-- nome: 42
-- numerico: 68
-- numerico_inteiro: 29
-- path: 5
-- placa: 1
-- telefone: 5
-- texto_generico: 175
-- texto_livre: 71
-- url: 10
-- CENTROCUSTO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CENTROCUSTO"
  where true
),
updated as (
  update "public"."CENTROCUSTO" as tgt
  set
      "CODIGO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CENTROCUSTO' as table_name, count(*) as affected_rows from updated;

-- CLICOMPRARESIDUO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLICOMPRARESIDUO"
  where true
),
updated as (
  update "public"."CLICOMPRARESIDUO" as tgt
  set
      "VALOR" = (((src.anon_seq * 37) % 999999999) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLICOMPRARESIDUO' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASAGUA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASAGUA"
  where true
),
updated as (
  update "public"."CLIDEMANDASAGUA" as tgt
  set
      "TIPOLANCAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "LOCALCOLETA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "PARAMETRO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "RESULTADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "LIMITEMAXIMO" = (((src.anon_seq * 37) % 999999999) + 1),
      "TECNICO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "VALORFATURA" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDEFATURA" = (((src.anon_seq * 37) % 999999999) + 1),
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASAGUA' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASANEXOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASANEXOS"
  where true
),
updated as (
  update "public"."CLIDEMANDASANEXOS" as tgt
  set
      "TIPODEMANDA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "CAMINHO" = left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), 40)::text,
      "NOMEARQUIVO" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 32)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASANEXOS' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASAR
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASAR"
  where true
),
updated as (
  update "public"."CLIDEMANDASAR" as tgt
  set
      "TIPOLANCAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "FONTEEMISSAO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "PARAMETRO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "METODO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "RESULTADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "LIMITEMAX" = (((src.anon_seq * 37) % 999999999) + 1),
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "ENQUADRAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASAR' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASCHECKLIST
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASCHECKLIST"
  where true
),
updated as (
  update "public"."CLIDEMANDASCHECKLIST" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASCHECKLIST' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASCOMBUSTIVEL
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASCOMBUSTIVEL"
  where true
),
updated as (
  update "public"."CLIDEMANDASCOMBUSTIVEL" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "EQUIPAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "PRODUTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "VOLUME" = (((src.anon_seq * 37) % 999999999) + 1),
      "HODOMETRO" = (((src.anon_seq * 37) % 999999999) + 1),
      "CONSUMOESTIMADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "CUSTO" = (((src.anon_seq * 37) % 999999999) + 1),
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASCOMBUSTIVEL' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASEFLUENTE
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASEFLUENTE"
  where true
),
updated as (
  update "public"."CLIDEMANDASEFLUENTE" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "LOCAL" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "PARAMETRO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "RESULTADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "LIMITE" = (((src.anon_seq * 37) % 999999999) + 1),
      "METODO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "CONFORME" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::text,
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASEFLUENTE' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASENERGIA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASENERGIA"
  where true
),
updated as (
  update "public"."CLIDEMANDASENERGIA" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "TIPOLANCAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "EQUIPAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "ENERGIACONSUMIDA" = (((src.anon_seq * 37) % 999999999) + 1),
      "CUSTO" = (((src.anon_seq * 37) % 999999999) + 1),
      "BENCHMARK" = (((src.anon_seq * 37) % 999999999) + 1),
      "VARIACAO" = (((src.anon_seq * 37) % 999999999) + 1),
      "META" = (((src.anon_seq * 37) % 999999999) + 1),
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASENERGIA' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASGERAIS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASGERAIS"
  where true
),
updated as (
  update "public"."CLIDEMANDASGERAIS" as tgt
  set
      "TITULO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "CATEGORIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "SUBCATEGORIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "PRIORIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "TIPODEMANDA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "ORIGEM" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "COMPLEXIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "MOTIVOCANCELAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASGERAIS' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASRESIDUOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASRESIDUOS"
  where true
),
updated as (
  update "public"."CLIDEMANDASRESIDUOS" as tgt
  set
      "TIPOLANCAMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "QUANTIDADE" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "VALOR" = (((src.anon_seq * 37) % 999999999) + 1),
      "REFERENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(10 - length('anon_'), 1), '0'), 10)::varchar,
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASRESIDUOS' as table_name, count(*) as affected_rows from updated;

-- CLIDEMANDASSOLO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIDEMANDASSOLO"
  where true
),
updated as (
  update "public"."CLIDEMANDASSOLO" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "LOCAL" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "PARAMETRO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "RESULTADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "LIMITEREFERENCIA" = (((src.anon_seq * 37) % 999999999) + 1),
      "METODO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "CONFORMIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::text,
      "FREQUENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIDEMANDASSOLO' as table_name, count(*) as affected_rows from updated;

-- CLIENTEPERFIS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTEPERFIS"
  where true
),
updated as (
  update "public"."CLIENTEPERFIS" as tgt
  set
      "NOME" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTEPERFIS' as table_name, count(*) as affected_rows from updated;

-- CLIENTESETORES
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESETORES"
  where true
),
updated as (
  update "public"."CLIENTESETORES" as tgt
  set
      "NOME" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESETORES' as table_name, count(*) as affected_rows from updated;

-- CLIENTESPERFILPERMTELA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESPERFILPERMTELA"
  where true
),
updated as (
  update "public"."CLIENTESPERFILPERMTELA" as tgt
  set
      "ESTADOTELA" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESPERFILPERMTELA' as table_name, count(*) as affected_rows from updated;

-- CLIENTESPERMISSOESTELA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESPERMISSOESTELA"
  where true
),
updated as (
  update "public"."CLIENTESPERMISSOESTELA" as tgt
  set
      "ESTADOTELA" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESPERMISSOESTELA' as table_name, count(*) as affected_rows from updated;

-- CLIENTESROTAS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESROTAS"
  where true
),
updated as (
  update "public"."CLIENTESROTAS" as tgt
  set
      "NOMEROTA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(28 - length('anonimo_'), 1), '0'), 28)::varchar,
      "NOMETELA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(43 - length('anonimo_'), 1), '0'), 43)::varchar,
      "NOMETELAREDUZIDO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(21 - length('anonimo_'), 1), '0'), 21)::varchar,
      "NOMEICONE" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "MENUPAI" = left('anon_' || lpad(src.anon_seq::text, greatest(17 - length('anon_'), 1), '0'), 17)::varchar,
      "SUBMENU" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESROTAS' as table_name, count(*) as affected_rows from updated;

-- CLIENTESUSUARIOPERMTELA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESUSUARIOPERMTELA"
  where true
),
updated as (
  update "public"."CLIENTESUSUARIOPERMTELA" as tgt
  set
      "ESTADOTELA" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESUSUARIOPERMTELA' as table_name, count(*) as affected_rows from updated;

-- CLIENTESUSUARIOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CLIENTESUSUARIOS"
  where true
),
updated as (
  update "public"."CLIENTESUSUARIOS" as tgt
  set
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar,
      "USUARIO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "SENHA" = left('anon_' || lpad(src.anon_seq::text, greatest(60 - length('anon_'), 1), '0'), 60)::varchar,
      "CARGO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "CODIGOTEMPORARIO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "TELEFONE" = left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, 12, '0'), 14)::text,
      "WHATSAPP" = left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, 12, '0'), 14)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CLIENTESUSUARIOS' as table_name, count(*) as affected_rows from updated;

-- CONDICAOPAGAMENTO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CONDICAOPAGAMENTO"
  where true
),
updated as (
  update "public"."CONDICAOPAGAMENTO" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "NUMEROPARCELAS" = (((src.anon_seq * 37) % 2147483646) + 1),
      "DIASENTREPARC" = (((src.anon_seq * 37) % 2147483646) + 1),
      "FORMAPAGTO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CONDICAOPAGAMENTO' as table_name, count(*) as affected_rows from updated;

-- CONTASPAGAR
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CONTASPAGAR"
  where true
),
updated as (
  update "public"."CONTASPAGAR" as tgt
  set
      "DOCUMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "NUMEROPARCELA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "VALORTOTAL" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "VALORPAGO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CONTASPAGAR' as table_name, count(*) as affected_rows from updated;

-- CONTASPAGARMOVTO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CONTASPAGARMOVTO"
  where true
),
updated as (
  update "public"."CONTASPAGARMOVTO" as tgt
  set
      "DOCUMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "NUMEROPARCELA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "VALORPAGO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(76::numeric / length('dados anonimizados - '))::int), 76)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CONTASPAGARMOVTO' as table_name, count(*) as affected_rows from updated;

-- CONTASRECEBER
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CONTASRECEBER"
  where true
),
updated as (
  update "public"."CONTASRECEBER" as tgt
  set
      "DOCUMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "NUMEROPARCELA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "VALORTOTAL" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "VALORPAGO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(34::numeric / length('dados anonimizados - '))::int), 34)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CONTASRECEBER' as table_name, count(*) as affected_rows from updated;

-- CONTASRECEBERMOVTO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."CONTASRECEBERMOVTO"
  where true
),
updated as (
  update "public"."CONTASRECEBERMOVTO" as tgt
  set
      "DOCUMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "NUMEROPARCELA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "VALORPAGO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(93::numeric / length('dados anonimizados - '))::int), 93)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'CONTASRECEBERMOVTO' as table_name, count(*) as affected_rows from updated;

-- DADOSEVENTOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."DADOSEVENTOS"
  where true
),
updated as (
  update "public"."DADOSEVENTOS" as tgt
  set
      "NOMEEVENTO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "QTDE" = (((src.anon_seq * 37) % 999999999) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'DADOSEVENTOS' as table_name, count(*) as affected_rows from updated;

-- DADOSINTEGRACAOMTR
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."DADOSINTEGRACAOMTR"
  where true
),
updated as (
  update "public"."DADOSINTEGRACAOMTR" as tgt
  set
      "UNIDADEMTR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "UF" = left('anon_' || lpad(src.anon_seq::text, greatest(2 - length('anon_'), 1), '0'), 2)::varchar,
      "USUARIO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(14 - length('anonimo_'), 1), '0'), 14)::varchar,
      "SENHA" = left('anon_' || lpad(src.anon_seq::text, greatest(11 - length('anon_'), 1), '0'), 11)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'DADOSINTEGRACAOMTR' as table_name, count(*) as affected_rows from updated;

-- FORNECEDORESFINANCEIRO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."FORNECEDORESFINANCEIRO"
  where true
),
updated as (
  update "public"."FORNECEDORESFINANCEIRO" as tgt
  set
      "RAZAOSOCIAL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "NOMEFANTASIA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "PESSOA" = left('anon_' || lpad(src.anon_seq::text, greatest(5 - length('anon_'), 1), '0'), 5)::varchar,
      "CNPJCPF" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "CEP" = left(lpad(((src.anon_seq * 7777777)::bigint)::text, 8, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 8)::varchar,
      "UF" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar,
      "MUNICIPIO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "ENDERECO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "NUMERO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "COMPLEMENTO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "BAIRRO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'FORNECEDORESFINANCEIRO' as table_name, count(*) as affected_rows from updated;

-- GRUPOCLIENTE
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."GRUPOCLIENTE"
  where true
),
updated as (
  update "public"."GRUPOCLIENTE" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'GRUPOCLIENTE' as table_name, count(*) as affected_rows from updated;

-- KANBANANEXOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANANEXOS"
  where true
),
updated as (
  update "public"."KANBANANEXOS" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(19::numeric / length('dados anonimizados - '))::int), 19)::varchar,
      "FILEURL" = left('anon_' || lpad(src.anon_seq::text, greatest(71 - length('anon_'), 1), '0'), 71)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANANEXOS' as table_name, count(*) as affected_rows from updated;

-- KANBANCARDS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANCARDS"
  where true
),
updated as (
  update "public"."KANBANCARDS" as tgt
  set
      "TITULO" = left('anon_' || lpad(src.anon_seq::text, greatest(23 - length('anon_'), 1), '0'), 23)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "ORDEM" = (((src.anon_seq * 37) % 2147483646) + 1),
      "VERSAOLIBERACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "COR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANCARDS' as table_name, count(*) as affected_rows from updated;

-- KANBANCHECKLIST
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANCHECKLIST"
  where true
),
updated as (
  update "public"."KANBANCHECKLIST" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANCHECKLIST' as table_name, count(*) as affected_rows from updated;

-- KANBANCOLUNAS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANCOLUNAS"
  where true
),
updated as (
  update "public"."KANBANCOLUNAS" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "ORDEM" = (((src.anon_seq * 37) % 2147483646) + 1),
      "COR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANCOLUNAS' as table_name, count(*) as affected_rows from updated;

-- KANBANCOMENTARIOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANCOMENTARIOS"
  where true
),
updated as (
  update "public"."KANBANCOMENTARIOS" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "ORDEM" = (((src.anon_seq * 37) % 2147483646) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANCOMENTARIOS' as table_name, count(*) as affected_rows from updated;

-- KANBANQUADROS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANQUADROS"
  where true
),
updated as (
  update "public"."KANBANQUADROS" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANQUADROS' as table_name, count(*) as affected_rows from updated;

-- KANBANTAGS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."KANBANTAGS"
  where true
),
updated as (
  update "public"."KANBANTAGS" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "COR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'KANBANTAGS' as table_name, count(*) as affected_rows from updated;

-- LOGS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."LOGS"
  where true
),
updated as (
  update "public"."LOGS" as tgt
  set
      "TEXTO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'LOGS' as table_name, count(*) as affected_rows from updated;

-- PARAMINTEGRACAOMTR
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PARAMINTEGRACAOMTR"
  where true
),
updated as (
  update "public"."PARAMINTEGRACAOMTR" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(21::numeric / length('dados anonimizados - '))::int), 21)::varchar,
      "URLBASE" = left('https://example.com/anon/' || src.anon_seq::text, 26)::varchar,
      "UF" = left('anon_' || lpad(src.anon_seq::text, greatest(2 - length('anon_'), 1), '0'), 2)::varchar,
      "AMBIENTE" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PARAMINTEGRACAOMTR' as table_name, count(*) as affected_rows from updated;

-- PERFISUSUARIO
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PERFISUSUARIO"
  where true
),
updated as (
  update "public"."PERFISUSUARIO" as tgt
  set
      "NOME" = left('anonimo_' || lpad(src.anon_seq::text, greatest(11 - length('anonimo_'), 1), '0'), 11)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PERFISUSUARIO' as table_name, count(*) as affected_rows from updated;

-- PLANOCONTAS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PLANOCONTAS"
  where true
),
updated as (
  update "public"."PLANOCONTAS" as tgt
  set
      "CODIGOCONTA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "NIVEL" = (((src.anon_seq * 37) % 2147483646) + 1),
      "CONTAPAI" = (((src.anon_seq * 37) % 2147483646) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PLANOCONTAS' as table_name, count(*) as affected_rows from updated;

-- PROPOSTAS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PROPOSTAS"
  where true
),
updated as (
  update "public"."PROPOSTAS" as tgt
  set
      "NUMEROPROPOSTA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "REVISAO" = (((src.anon_seq * 37) % 2147483646) + 1),
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "CNPJCPF" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 11, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 11)::varchar,
      "RAZAOSOCIAL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(15 - length('anonimo_'), 1), '0'), 15)::varchar,
      "ENDERECO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "ORIGEM" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "VALORPROPOSTO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "VALORFECHADO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "VALORDESCONTO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "QTDPARCELAS" = (((src.anon_seq * 37) % 2147483646) + 1),
      "CATEGORIA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "CONTA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "SERVICOS" = left(repeat('dados anonimizados - ', ceil(36::numeric / length('dados anonimizados - '))::int), 36)::varchar,
      "OBSERVACOESDAPROPOSTA" = left(repeat('dados anonimizados - ', ceil(58::numeric / length('dados anonimizados - '))::int), 58)::varchar,
      "OBSERVACOESINTERNAS" = left(repeat('dados anonimizados - ', ceil(344::numeric / length('dados anonimizados - '))::int), 344)::varchar,
      "OBSERVACOESFINANCEIRAS" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "RESUMOPROPOSTA" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::varchar,
      "PRIORIDADEINTERNA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "POSSIVEISCONCORRENTES" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "VALORENTRADA" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "TIPOVENCIMENTO" = left('anon_' || lpad(src.anon_seq::text, greatest(11 - length('anon_'), 1), '0'), 11)::text,
      "TIPOCOBRANCA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "VALORCALCULADO" = ((((src.anon_seq * 37) % 999999999)::numeric) + ((src.anon_seq % 100)::numeric / 100))::numeric,
      "NUMCNPJ" = (((src.anon_seq * 37) % 2147483646) + 1),
      "TIPOTAXA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PROPOSTAS' as table_name, count(*) as affected_rows from updated;

-- PROPOSTASCNPJ
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PROPOSTASCNPJ"
  where true
),
updated as (
  update "public"."PROPOSTASCNPJ" as tgt
  set
      "CNPJCPF" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::text,
      "RAZAOSOCIAL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::text,
      "ENDERECO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PROPOSTASCNPJ' as table_name, count(*) as affected_rows from updated;

-- PROPOSTASCONTATOS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."PROPOSTASCONTATOS"
  where true
),
updated as (
  update "public"."PROPOSTASCONTATOS" as tgt
  set
      "NOME" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "FUNCAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "TELEFONE" = left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, 11, '0'), 13)::varchar,
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'PROPOSTASCONTATOS' as table_name, count(*) as affected_rows from updated;

-- ROTASTELAS
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."ROTASTELAS"
  where true
),
updated as (
  update "public"."ROTASTELAS" as tgt
  set
      "NOMEROTA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(12 - length('anonimo_'), 1), '0'), 12)::varchar,
      "NOMETELA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(25 - length('anonimo_'), 1), '0'), 25)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'ROTASTELAS' as table_name, count(*) as affected_rows from updated;

-- SITUACAOCLIENTE
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."SITUACAOCLIENTE"
  where true
),
updated as (
  update "public"."SITUACAOCLIENTE" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'SITUACAOCLIENTE' as table_name, count(*) as affected_rows from updated;

-- SITUACAOEXECDEMANDA
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."SITUACAOEXECDEMANDA"
  where true
),
updated as (
  update "public"."SITUACAOEXECDEMANDA" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "COR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'SITUACAOEXECDEMANDA' as table_name, count(*) as affected_rows from updated;

-- UserDetalhes
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."UserDetalhes"
  where true
),
updated as (
  update "public"."UserDetalhes" as tgt
  set
      "email" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar,
      "userName" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "papel" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "cli_nklgama" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "uuid" = left('anon_' || lpad(src.anon_seq::text, greatest(36 - length('anon_'), 1), '0'), 36)::text,
      "senha" = left('anon_' || lpad(src.anon_seq::text, greatest(60 - length('anon_'), 1), '0'), 60)::varchar,
      "codigotemporario" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'UserDetalhes' as table_name, count(*) as affected_rows from updated;

-- avaliacoes
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."avaliacoes"
  where true
),
updated as (
  update "public"."avaliacoes" as tgt
  set
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(26::numeric / length('dados anonimizados - '))::int), 26)::text,
      "segmento" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "tipo" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "form" = NULL,
      "cli_nklgama" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "secoes" = NULL,
      "tipoPercentual" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "PATHANEXO" = left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), 20)::varchar,
      "PERCENTUAL" = (((src.anon_seq * 37) % 999999999) + 1),
      "ANTIGO" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar,
      "ANOTACOES" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'avaliacoes' as table_name, count(*) as affected_rows from updated;

-- avaliacoesAnexos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."avaliacoesAnexos"
  where true
),
updated as (
  update "public"."avaliacoesAnexos" as tgt
  set
      "PATHANEXO" = left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), 20)::varchar,
      "COMENTARIO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'avaliacoesAnexos' as table_name, count(*) as affected_rows from updated;

-- avaliacoesItem
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."avaliacoesItem"
  where true
),
updated as (
  update "public"."avaliacoesItem" as tgt
  set
      "SECAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "PESOSECAO" = (((src.anon_seq * 37) % 999999999) + 1),
      "PESOICA" = (((src.anon_seq * 37) % 999999999) + 1),
      "PESOIDO" = (((src.anon_seq * 37) % 999999999) + 1),
      "PESOIDG" = (((src.anon_seq * 37) % 999999999) + 1),
      "NOTASECAO" = (((src.anon_seq * 37) % 999999999) + 1),
      "SETOR" = left('anon_' || lpad(src.anon_seq::text, greatest(22 - length('anon_'), 1), '0'), 22)::varchar,
      "INDICADOR" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "DESCQUESTAO" = left('anon_' || lpad(src.anon_seq::text, greatest(182 - length('anon_'), 1), '0'), 182)::text,
      "NOTAQUESTAO" = (((src.anon_seq * 37) % 999999999) + 1),
      "OBSPERGUNTA" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "DESCRICAOACAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "PRIORIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "MEDIAINDICADOR" = (((src.anon_seq * 37) % 999999999) + 1),
      "NOTAPONDERADA" = (((src.anon_seq * 37) % 999999999) + 1),
      "PESOINDICADOR" = (((src.anon_seq * 37) % 999999999) + 1),
      "ORDEMSETOR" = (((src.anon_seq * 37) % 2147483646) + 1),
      "ORDEMITEM" = (((src.anon_seq * 37) % 2147483646) + 1),
      "IMPACTOS" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "MODO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'avaliacoesItem' as table_name, count(*) as affected_rows from updated;

-- centrocusto
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."centrocusto"
  where true
),
updated as (
  update "public"."centrocusto" as tgt
  set
      "CODIGO" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::varchar,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'centrocusto' as table_name, count(*) as affected_rows from updated;

-- clientes
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."clientes"
  where true
),
updated as (
  update "public"."clientes" as tgt
  set
      "CODKLGAMA" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "empresa" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "RAZAOSOCIAL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(27 - length('anonimo_'), 1), '0'), 27)::varchar,
      "CNPJCPF" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "cli_cpf" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "cli_segmento" = left('anon_' || lpad(src.anon_seq::text, greatest(16 - length('anon_'), 1), '0'), 16)::varchar,
      "UF" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar,
      "MUNICIPIO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "BAIRRO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "ENDERECO" = left(repeat('dados anonimizados - ', ceil(22::numeric / length('dados anonimizados - '))::int), 22)::varchar,
      "NUMERO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "COMPLEMENTO" = left(repeat('dados anonimizados - ', ceil(16::numeric / length('dados anonimizados - '))::int), 16)::varchar,
      "NOMEREPRESENTANTE" = left('anonimo_' || lpad(src.anon_seq::text, greatest(14 - length('anonimo_'), 1), '0'), 14)::varchar,
      "CPFREPRESENTANTE" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 11, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 11)::varchar,
      "DATANASCREPRESENTANTE" = ((date '1985-01-01' + ((src.anon_seq % 12000) * interval '1 day'))::date),
      "cli_contatos" = NULL,
      "PESSOA" = left('anon_' || lpad(src.anon_seq::text, greatest(5 - length('anon_'), 1), '0'), 5)::varchar,
      "cli_logins" = NULL,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "SENHAPORTAL" = left('anon_' || lpad(src.anon_seq::text, greatest(9 - length('anon_'), 1), '0'), 9)::varchar,
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 18)::varchar,
      "CEP" = left(lpad(((src.anon_seq * 7777777)::bigint)::text, 8, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 8)::varchar,
      "NOMEFANTASIA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(27 - length('anonimo_'), 1), '0'), 27)::varchar,
      "EMAILCOMERCIAL" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar,
      "EMAILFINANCEIRO" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar,
      "TIPOCOBRANCA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'clientes' as table_name, count(*) as affected_rows from updated;

-- clientesContatos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."clientesContatos"
  where true
),
updated as (
  update "public"."clientesContatos" as tgt
  set
      "NOME" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "FUNCAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "TELEFONE" = left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, 11, '0'), 13)::varchar,
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'clientesContatos' as table_name, count(*) as affected_rows from updated;

-- clientesCredenciais
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."clientesCredenciais"
  where true
),
updated as (
  update "public"."clientesCredenciais" as tgt
  set
      "USUARIO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::varchar,
      "SENHA" = left('anon_' || lpad(src.anon_seq::text, greatest(20 - length('anon_'), 1), '0'), 20)::varchar,
      "USUARIO2" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::varchar,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'clientesCredenciais' as table_name, count(*) as affected_rows from updated;

-- configVersao
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."configVersao"
  where true
),
updated as (
  update "public"."configVersao" as tgt
  set
      "NUMEROVERSAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'configVersao' as table_name, count(*) as affected_rows from updated;

-- custoResiduo
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."custoResiduo"
  where true
),
updated as (
  update "public"."custoResiduo" as tgt
  set
      "TIPOCUSTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "VALOR" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "ESTADOFISICO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "VALORDENSIDADE" = (((src.anon_seq * 37) % 999999999) + 1),
      "UNIDADEDESC" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "DESCPRECO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'custoResiduo' as table_name, count(*) as affected_rows from updated;

-- dadosDespesas
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."dadosDespesas"
  where true
),
updated as (
  update "public"."dadosDespesas" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(24::numeric / length('dados anonimizados - '))::int), 24)::varchar,
      "VALOR" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDECONSUMO" = (((src.anon_seq * 37) % 999999999) + 1),
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "LINKANEXO" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "NOMEARQUIVO" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'dadosDespesas' as table_name, count(*) as affected_rows from updated;

-- dadosMTR
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."dadosMTR"
  where true
),
updated as (
  update "public"."dadosMTR" as tgt
  set
      "NUMEROMTR" = left('anon_' || lpad(src.anon_seq::text, greatest(10 - length('anon_'), 1), '0'), 10)::varchar,
      "NOMEDESTINADOR" = left('anonimo_' || lpad(src.anon_seq::text, greatest(40 - length('anonimo_'), 1), '0'), 40)::varchar,
      "CNPJCPFDESTINADOR" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "NOMETRANSPORTADORA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(40 - length('anonimo_'), 1), '0'), 40)::varchar,
      "CNPJCPFTRANSPORTADORA" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "NOMEGERADOR" = left('anonimo_' || lpad(src.anon_seq::text, greatest(29 - length('anonimo_'), 1), '0'), 29)::varchar,
      "CNPJCPFGERADOR" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "NOMEMOTORISTA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(18 - length('anonimo_'), 1), '0'), 18)::varchar,
      "PLACAVEICULO" = left('ABC' || lpad(src.anon_seq::text, greatest(7 - length('ABC'), 1), '0'), 7)::varchar,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(9 - length('anon_'), 1), '0'), 9)::varchar,
      "NOMERESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::varchar,
      "CLASSE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "QTDETONELADA" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDEUNIDADE" = (((src.anon_seq * 37) % 999999999) + 1),
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(28::numeric / length('dados anonimizados - '))::int), 28)::varchar,
      "TECNOLOGIAFINAL" = left('anon_' || lpad(src.anon_seq::text, greatest(21 - length('anon_'), 1), '0'), 21)::varchar,
      "CDF" = left('anon_' || lpad(src.anon_seq::text, greatest(11 - length('anon_'), 1), '0'), 11)::varchar,
      "VALORRECEITA" = (((src.anon_seq * 37) % 999999999) + 1),
      "VALORDESPESA" = (((src.anon_seq * 37) % 999999999) + 1),
      "TOTAL" = (((src.anon_seq * 37) % 999999999) + 1),
      "DIFERENCA" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDERESIDUO" = (((src.anon_seq * 37) % 999999999) + 1),
      "LINKMTR" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "LINKCDF" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "LINKPDFNOTA" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "LINKXMLNOTA" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "NOMEARQUIVOMTR" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::varchar,
      "NOMEARQUIVOCDF" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::varchar,
      "NOMEARQUIVONOTAPDF" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 16)::varchar,
      "NOMEARQUIVONOTAXML" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::varchar,
      "RESIDUO" = left('anon_' || lpad(src.anon_seq::text, greatest(130 - length('anon_'), 1), '0'), 130)::varchar,
      "CODIGOKLGAMA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'dadosMTR' as table_name, count(*) as affected_rows from updated;

-- dadosMTRAnexo
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."dadosMTRAnexo"
  where true
),
updated as (
  update "public"."dadosMTRAnexo" as tgt
  set
      "TIPO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "LINK" = left('https://example.com/anon/' || src.anon_seq::text, 26)::varchar,
      "NOMEARQUIVO" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 16)::varchar,
      "LOCAL" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'dadosMTRAnexo' as table_name, count(*) as affected_rows from updated;

-- demandas
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."demandas"
  where true
),
updated as (
  update "public"."demandas" as tgt
  set
      "processo" = left('anon_' || lpad(src.anon_seq::text, greatest(13 - length('anon_'), 1), '0'), 13)::text,
      "cli_nklgama" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "ATIVIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(37 - length('anon_'), 1), '0'), 37)::varchar,
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(103::numeric / length('dados anonimizados - '))::int), 103)::varchar,
      "LEMBRARANTES" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "TIPOLEMBRETE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "status" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::text,
      "checklist" = NULL,
      "cli_status" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "cli_razaoSocial" = left('anonimo_' || lpad(src.anon_seq::text, greatest(30 - length('anonimo_'), 1), '0'), 30)::text,
      "temp" = left('anon_' || lpad(src.anon_seq::text, greatest(134 - length('anon_'), 1), '0'), 134)::varchar,
      "NUMEROOCORRENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "SEQUENCIAOCORRENCIA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "ORDEMEXECUCAO" = (((src.anon_seq * 37) % 2147483646) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'demandas' as table_name, count(*) as affected_rows from updated;

-- demandasAnexos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."demandasAnexos"
  where true
),
updated as (
  update "public"."demandasAnexos" as tgt
  set
      "NOMEARQUIVO" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::text,
      "URL" = left('https://example.com/anon/' || src.anon_seq::text, 26)::text,
      "COMENTARIO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'demandasAnexos' as table_name, count(*) as affected_rows from updated;

-- demandasHist
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."demandasHist"
  where true
),
updated as (
  update "public"."demandasHist" as tgt
  set
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'demandasHist' as table_name, count(*) as affected_rows from updated;

-- demandasItem
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."demandasItem"
  where true
),
updated as (
  update "public"."demandasItem" as tgt
  set
      "ATIVIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(40 - length('anon_'), 1), '0'), 40)::varchar,
      "ORDEM" = (((src.anon_seq * 37) % 2147483646) + 1),
      "OBSERVACOES" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'demandasItem' as table_name, count(*) as affected_rows from updated;

-- desempenhoAmbientalUnidade
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."desempenhoAmbientalUnidade"
  where true
),
updated as (
  update "public"."desempenhoAmbientalUnidade" as tgt
  set
      "ASPECTO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "PERCESPERADO" = (((src.anon_seq * 37) % 999999999) + 1),
      "PERCREAL" = (((src.anon_seq * 37) % 999999999) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'desempenhoAmbientalUnidade' as table_name, count(*) as affected_rows from updated;

-- documentos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."documentos"
  where true
),
updated as (
  update "public"."documentos" as tgt
  set
      "tipo" = left('anon_' || lpad(src.anon_seq::text, greatest(25 - length('anon_'), 1), '0'), 25)::text,
      "PERMISSAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "LINK" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "cli_nklgama" = (((src.anon_seq * 37)::bigint % 9223372036854775806) + 1),
      "TITULO" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "LINKDOWNLOAD" = left('https://example.com/anon/' || src.anon_seq::text, 27)::varchar,
      "NOMEARQUIVO" = left('arquivo_anon_' || lpad(src.anon_seq::text, 6, '0'), 19)::varchar,
      "GRUPO" = left('anon_' || lpad(src.anon_seq::text, greatest(5 - length('anon_'), 1), '0'), 5)::varchar,
      "PATHLOCAL" = left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), 20)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'documentos' as table_name, count(*) as affected_rows from updated;

-- fornecedores
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."fornecedores"
  where true
),
updated as (
  update "public"."fornecedores" as tgt
  set
      "RAZAOSOCIAL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(34 - length('anonimo_'), 1), '0'), 34)::varchar,
      "NOMEFANTASIA" = left('anonimo_' || lpad(src.anon_seq::text, greatest(34 - length('anonimo_'), 1), '0'), 34)::varchar,
      "PESSOA" = left('anon_' || lpad(src.anon_seq::text, greatest(5 - length('anon_'), 1), '0'), 5)::varchar,
      "CNPJCPF" = left(lpad(((src.anon_seq * 1111111)::bigint)::text, 14, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 14)::varchar,
      "SITUACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "CEP" = left(lpad(((src.anon_seq * 7777777)::bigint)::text, 8, substr('1234567890', (((src.anon_seq % 10) + 1)::int), 1)), 8)::varchar,
      "UF" = left('anon_' || lpad(src.anon_seq::text, greatest(3 - length('anon_'), 1), '0'), 3)::varchar,
      "MUNICIPIO" = left(repeat('dados anonimizados - ', ceil(40::numeric / length('dados anonimizados - '))::int), 40)::varchar,
      "ENDERECO" = left(repeat('dados anonimizados - ', ceil(40::numeric / length('dados anonimizados - '))::int), 40)::varchar,
      "NUMERO" = left('anon_' || lpad(src.anon_seq::text, greatest(10 - length('anon_'), 1), '0'), 10)::varchar,
      "COMPLEMENTO" = left(repeat('dados anonimizados - ', ceil(40::numeric / length('dados anonimizados - '))::int), 40)::varchar,
      "BAIRRO" = left(repeat('dados anonimizados - ', ceil(40::numeric / length('dados anonimizados - '))::int), 40)::varchar,
      "EMAIL" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'fornecedores' as table_name, count(*) as affected_rows from updated;

-- leads_fenabrave
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."leads_fenabrave"
  where true
),
updated as (
  update "public"."leads_fenabrave" as tgt
  set
      "nome" = left('anonimo_' || lpad(src.anon_seq::text, greatest(19 - length('anonimo_'), 1), '0'), 19)::varchar,
      "email" = left('anon.' || src.anon_seq::text || '@example.com', 19)::varchar,
      "telefone" = left('55' || lpad((((src.anon_seq * 97) % 1000000000000)::bigint)::text, 13, '0'), 15)::varchar,
      "empresa" = left('anon_' || lpad(src.anon_seq::text, greatest(15 - length('anon_'), 1), '0'), 15)::varchar,
      "cargo" = left('anon_' || lpad(src.anon_seq::text, greatest(15 - length('anon_'), 1), '0'), 15)::varchar,
      "interesse" = left('anon_' || lpad(src.anon_seq::text, greatest(15 - length('anon_'), 1), '0'), 15)::varchar,
      "origem" = left('anon_' || lpad(src.anon_seq::text, greatest(13 - length('anon_'), 1), '0'), 13)::varchar,
      "material_solicitado" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "utm_source" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "utm_medium" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "utm_campaign" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::varchar,
      "user_agent" = left('anon_' || lpad(src.anon_seq::text, greatest(134 - length('anon_'), 1), '0'), 134)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'leads_fenabrave' as table_name, count(*) as affected_rows from updated;

-- orgaos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."orgaos"
  where true
),
updated as (
  update "public"."orgaos" as tgt
  set
      "orgao" = left('anon_' || lpad(src.anon_seq::text, greatest(14 - length('anon_'), 1), '0'), 14)::text,
      "empresa" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "descricao" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'orgaos' as table_name, count(*) as affected_rows from updated;

-- planoAcao
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."planoAcao"
  where true
),
updated as (
  update "public"."planoAcao" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(32::numeric / length('dados anonimizados - '))::int), 32)::varchar,
      "DESCDETALHADA" = left('anon_' || lpad(src.anon_seq::text, greatest(235 - length('anon_'), 1), '0'), 235)::varchar,
      "USUARIOCADASTRO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(17 - length('anonimo_'), 1), '0'), 17)::varchar,
      "USUARIOALTERACAO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(17 - length('anonimo_'), 1), '0'), 17)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'planoAcao' as table_name, count(*) as affected_rows from updated;

-- planoAcaoAnexos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."planoAcaoAnexos"
  where true
),
updated as (
  update "public"."planoAcaoAnexos" as tgt
  set
      "PATHANEXO" = left('/anon/arquivo_' || lpad(src.anon_seq::text, 6, '0'), 20)::varchar,
      "COMENTARIO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::varchar,
      "TIPOANEXO" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'planoAcaoAnexos' as table_name, count(*) as affected_rows from updated;

-- planoAcaoHistoricoItem
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."planoAcaoHistoricoItem"
  where true
),
updated as (
  update "public"."planoAcaoHistoricoItem" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(20::numeric / length('dados anonimizados - '))::int), 20)::varchar,
      "USUARIO" = left('anonimo_' || lpad(src.anon_seq::text, greatest(16 - length('anonimo_'), 1), '0'), 16)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'planoAcaoHistoricoItem' as table_name, count(*) as affected_rows from updated;

-- planoAcaoItem
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."planoAcaoItem"
  where true
),
updated as (
  update "public"."planoAcaoItem" as tgt
  set
      "SETOR" = left('anon_' || lpad(src.anon_seq::text, greatest(33 - length('anon_'), 1), '0'), 33)::text,
      "SEQUENCIA" = (((src.anon_seq * 37) % 2147483646) + 1),
      "LOCAL" = left('anon_' || lpad(src.anon_seq::text, greatest(21 - length('anon_'), 1), '0'), 21)::text,
      "ACAO" = left('anon_' || lpad(src.anon_seq::text, greatest(49 - length('anon_'), 1), '0'), 49)::text,
      "MODO" = left('anon_' || lpad(src.anon_seq::text, greatest(102 - length('anon_'), 1), '0'), 102)::text,
      "PRIORIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "RESPONSAVEL" = left('anonimo_' || lpad(src.anon_seq::text, greatest(10 - length('anonimo_'), 1), '0'), 10)::text,
      "PREVISAOINICIO" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "RECORRENCIA" = left('anon_' || lpad(src.anon_seq::text, greatest(10 - length('anon_'), 1), '0'), 10)::text,
      "OBSERVACAO" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'planoAcaoItem' as table_name, count(*) as affected_rows from updated;

-- processos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."processos"
  where true
),
updated as (
  update "public"."processos" as tgt
  set
      "processo" = left('anon_' || lpad(src.anon_seq::text, greatest(12 - length('anon_'), 1), '0'), 12)::text,
      "descricao" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'processos' as table_name, count(*) as affected_rows from updated;

-- residuos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."residuos"
  where true
),
updated as (
  update "public"."residuos" as tgt
  set
      "capitulo" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "descricaocapitulo" = left(repeat('dados anonimizados - ', ceil(80::numeric / length('dados anonimizados - '))::int), 80)::text,
      "subcapitulo" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "descsubcapitulo" = left('anon_' || lpad(src.anon_seq::text, greatest(24 - length('anon_'), 1), '0'), 24)::text,
      "residuo" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "descresiduo" = left('anon_' || lpad(src.anon_seq::text, greatest(80 - length('anon_'), 1), '0'), 80)::text,
      "perigoso" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar,
      "unidade" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text,
      "descresumida" = left('anon_' || lpad(src.anon_seq::text, greatest(17 - length('anon_'), 1), '0'), 17)::text,
      "tipo" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::text
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'residuos' as table_name, count(*) as affected_rows from updated;

-- residuosEletronicos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."residuosEletronicos"
  where true
),
updated as (
  update "public"."residuosEletronicos" as tgt
  set
      "DESCRICAO" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "UNIDADE" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "QUANTIDADE" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDEUNITARIO" = (((src.anon_seq * 37) % 999999999) + 1),
      "QTDETOTAL" = (((src.anon_seq * 37) % 999999999) + 1),
      "COMENTARIOS" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'residuosEletronicos' as table_name, count(*) as affected_rows from updated;

-- segmentos
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."segmentos"
  where true
),
updated as (
  update "public"."segmentos" as tgt
  set
      "seguimento" = left('anon_' || lpad(src.anon_seq::text, greatest(13 - length('anon_'), 1), '0'), 13)::varchar,
      "empresa" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar,
      "descricao" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "teste" = (((src.anon_seq * 37) % 2147483646) + 1),
      "percgeral" = (((src.anon_seq * 37) % 999999999) + 1),
      "percar" = (((src.anon_seq * 37) % 999999999) + 1),
      "percsolo" = (((src.anon_seq * 37) % 999999999) + 1),
      "percagua" = (((src.anon_seq * 37) % 999999999) + 1),
      "percica" = (((src.anon_seq * 37) % 999999999) + 1),
      "percido" = (((src.anon_seq * 37) % 999999999) + 1),
      "percidg" = (((src.anon_seq * 37) % 999999999) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'segmentos' as table_name, count(*) as affected_rows from updated;

-- status
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."status"
  where true
),
updated as (
  update "public"."status" as tgt
  set
      "status" = left('anon_' || lpad(src.anon_seq::text, greatest(9 - length('anon_'), 1), '0'), 9)::text,
      "descricao" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "cor" = left('anon_' || lpad(src.anon_seq::text, greatest(8 - length('anon_'), 1), '0'), 8)::varchar
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'status' as table_name, count(*) as affected_rows from updated;

-- tipoDocumento
with src as (
  select
    ctid as anon_row_ref,
    row_number() over (order by ctid) as anon_seq
  from "public"."tipoDocumento"
  where true
),
updated as (
  update "public"."tipoDocumento" as tgt
  set
      "tipo" = left('anon_' || lpad(src.anon_seq::text, greatest(15 - length('anon_'), 1), '0'), 15)::text,
      "descricao" = left(repeat('dados anonimizados - ', ceil(18::numeric / length('dados anonimizados - '))::int), 18)::varchar,
      "grupo" = left('anon_' || lpad(src.anon_seq::text, greatest(1 - length('anon_'), 1), '0'), 1)::varchar,
      "temp" = (((src.anon_seq * 37) % 999999999) + 1)
  from src
  where tgt.ctid = src.anon_row_ref
  returning 1
)
select 'tipoDocumento' as table_name, count(*) as affected_rows from updated;

commit;
