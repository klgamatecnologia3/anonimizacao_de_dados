# Anonimizacao de Dados

Repositorio para gerar e executar scripts de anonimização em banco PostgreSQL, com foco em preparar bases de homologacao, testes e demonstracoes sem expor dados reais.

## Objetivo deste fluxo

O fluxo principal deste projeto e:

1. executar o script JavaScript que monta o SQL de anonimização;
2. revisar o arquivo SQL gerado;
3. executar o SQL no banco desejado.

Arquivos principais:

- gerador: `scripts/zero-generate-full-anonymization-sql.js`
- saida SQL: `sql/zero-full-anonymization.sql`

## Pre-requisitos

Antes de executar, tenha instalado:

- Node.js 18 ou superior
- npm
- PostgreSQL acessivel pela maquina que vai rodar o script

## Instalacao

No diretorio do projeto, instale as dependencias:

```bash
npm install
```

## Configuracao do ambiente

O script le as configuracoes do arquivo `.env.script`.

Exemplo minimo para ambiente local:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=anon_teste
DB_USER=postgres
DB_PASSWORD=postgres
DB_SSL=false
DB_SCHEMA=public
```

Voce tambem pode usar `DATABASE_URL` em vez das variaveis separadas.

## Como fazer o dump da base antes de anonimizar

O fluxo recomendado e trabalhar sobre uma copia local da base, nunca direto na origem.

Exemplo com `pg_dump` para gerar um backup no formato custom:

```bash
pg_dump \
  --host=SEU_HOST \
  --port=5432 \
  --username=postgres \
  --dbname=postgres \
  --format=custom \
  --no-owner \
  --no-privileges \
  --file=backup_base.dump
```

Quando o `pg_dump` pedir senha, use a senha do banco de origem que esta sofrendo o dump.

Depois, restaure esse backup em uma base local, por exemplo `anon_teste`:

```bash
pg_restore \
  --host=localhost \
  --port=5432 \
  --username=postgres \
  --dbname=anon_teste \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  backup_base.dump
```

Quando o `pg_restore` pedir senha, use a senha do PostgreSQL local, isto e, da base onde o backup sera restaurado.

Fluxo resumido:

1. gerar o dump da base de origem com `pg_dump`;
2. restaurar localmente com `pg_restore`;
3. apontar o `.env.script` para a base local;
4. gerar e revisar o SQL de anonimização;
5. executar a anonimização na copia local.

O guia completo desse processo esta em [docs/passo-a-passo-base-local-e-anonimizacao.md](/c:/projetos/anonimizacao_de_dados/docs/passo-a-passo-base-local-e-anonimizacao.md).

## Importante antes de gerar o SQL

Hoje o arquivo [scripts/zero-generate-full-anonymization-sql.js](/c:/projetos/anonimizacao_de_dados/scripts/zero-generate-full-anonymization-sql.js) esta com a constante `EXECUTE_DIRECTLY_IN_DATABASE = true`.

Com esse valor, o script executa a anonimização diretamente no banco e nao grava o arquivo SQL em disco.

Para seguir o fluxo recomendado de:

1. gerar o SQL;
2. revisar o SQL;
3. executar o SQL depois;

altere temporariamente essa constante para `false`:

```js
const EXECUTE_DIRECTLY_IN_DATABASE = false;
```

Quando essa constante estiver como `false`, a saida sera gravada em `sql/zero-full-anonymization.sql`.

## Como gerar o SQL

Execute:

```bash
npm run zero-generate-full-anonymization-sql
```

Se tudo estiver correto, o projeto vai gerar ou sobrescrever o arquivo:

- [sql/zero-full-anonymization.sql](/c:/projetos/anonimizacao_de_dados/sql/zero-full-anonymization.sql)

## Como revisar o SQL

Antes de rodar no banco, valide principalmente:

- se o banco configurado no `.env.script` e realmente o ambiente esperado;
- se o schema configurado em `DB_SCHEMA` esta correto;
- se as tabelas e colunas afetadas fazem sentido;
- se a regra de preservacao esperada continua correta.

O SQL gerado abre com `begin;` e fecha com `commit;`, entao ele roda em transacao.

## Como executar o SQL

Depois da revisao, execute o arquivo SQL no PostgreSQL usando a sua ferramenta preferida.

Exemplo com `psql`:

```bash
psql -h localhost -p 5432 -U postgres -d anon_teste -f sql/zero-full-anonymization.sql
```

Se o seu ambiente exigir senha, o `psql` vai solicitar durante a execucao, salvo se ela ja estiver configurada por variavel de ambiente ou arquivo de credenciais.

## Boas praticas recomendadas

- faca backup antes de executar qualquer anonimização;
- rode primeiro em uma base restaurada de teste ou homologacao;
- nao execute em producao sem validacao explicita;
- revise o SQL gerado sempre que houver mudanca de schema;
- confirme se a preservacao de registros especiais, como `public.clientes.id = 1`, continua aderente a regra esperada.

## Comando principal

Resumo rapido do fluxo:

```bash
npm install
npm run zero-generate-full-anonymization-sql
psql -h localhost -p 5432 -U postgres -d anon_teste -f sql/zero-full-anonymization.sql
```
