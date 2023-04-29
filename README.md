# My TL;DR Of A Curious Moon

The idea of the repository is to have a streamlined version of the teachings I had per chapter, focused on the Postgres itself. I found it interesting to change the database to avoid a simple copy/paste by myself. I chose a public dataset from the Brazilian government regarding confiscated cigarettes (and destroyed)[^1], that I may (or may not) change in the future.

> [A Curious Moon by Rob Conery](https://bigmachine.io/products/a-curious-moon/)

## Before the book

In this repository we will use docker-compose to run a local postgres instance, to start run:

```bash
docker compose up --remove-orphans [-d]
# or 
sh scripts/00_start.sh 
```

To use the psql CLI[^2]:

```bash
sh scripts/10_psql.sh
# or directly commands
sh scripts/10_psql.sh <<< 'select 1;'
sh scripts/10_psql.sh < my_sql.sql
```
---

## Transit

- Respect the ETL (extract, transform, load)

- Before a `create` must have a `drop * if exists [cascade]`

- Create a schema just for importing the data with text type

- Put everything in an idempotent script
  
## In Orbit

- Create lookup tables: reduce repetitions and could speedup search. A new table with all distinct values from the given coloumn (of the import.* table), with a primary key (that will be used as foreign key)

- Date in Postgres is stored as a UTC
- TIMESTAMPT: values in UTC
- TIMESTAMPTZ: converts TIMESTAMP values (UTC) to the client's session time zone 
  
- make clean && make

## Flyby

- A query is `Sargeable`(Search ARGument ABLE) if it can take advantage of an index to speed up the execution of the query
- Avoid `LIKE %*` as it is `non-sargable`
- `ILIKE` is case-insensitive

## A Bent Field

- Create a view to make querying easier (and drop if exists)
- \x: toggle expanded display (table vs record by record)
- \H: change output to html layout
- \o file_name: change output to a file
- Full-text indexing: `to_tsvector(my_text_column)` and `search @@ to_tsquery('my_search_query')`
- GIN: Generalized Inverted Index (key, posting list)
- Materialized View: a view does not store data, a `Materialized View` is stored in disk (and so, allowed to create an index). Once the original data is updated, it is necessary to update the materialized view: `REFRESH MATERIALIZED VIEW my_view_name`

---

[^1]: Data From: https://dados.gov.br/dados/conjuntos-dados/destinacoes-de-mercadorias-apreendidas

[^2]: I would like to thank to [Giovanni](https://giovannipcarvalho.github.io/2023/04/03/postgresql-and-psql-in-docker.html) for the psql script.
