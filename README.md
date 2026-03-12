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
