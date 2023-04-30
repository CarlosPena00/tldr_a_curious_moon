# My TL;DR Of A Curious Moon

The idea of the repository is to have a streamlined version of the teachings I had per chapter[^1], focused on the Postgres itself. I found it interesting to change the database to avoid a simple copy/paste by myself. I chose a public dataset from the Brazilian government regarding confiscated cigarettes (and destroyed)[^2], that I may (or may not) change in the future.

> [A Curious Moon by Rob Conery](https://bigmachine.io/products/a-curious-moon/)

## Before the book

In this repository we will use docker-compose to run a local postgres instance, to start run:

```bash
docker compose up --remove-orphans [-d]
# or
sh scripts/00_start.sh
```

To use the psql CLI[^3]:

```bash
sh scripts/10_psql.sh
# or directly commands
sh scripts/10_psql.sh <<< 'select 1;'
sh scripts/10_psql.sh < my_sql.sql
```
---

## Transit

- Respect the ETL (extract, [transform](sql/normalize.sql), load)
- Before a `create` must have a `drop * if exists [cascade]`
- Create a [schema](sql/import.sql) just for importing the data with text type
- Put everything in an idempotent script (same input same output)

## In Orbit

- Create lookup tables: reduce repetitions and could speedup search. A new table with all distinct values from the given coloumn (of the import.* table), with a primary key (that will be used as foreign key)
- Date in Postgres is stored as a UTC
- TIMESTAMPT: values in UTC
- TIMESTAMPTZ: converts TIMESTAMP values (UTC) to the client's session time zone
- make clean && [make](Makefile)

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

## Sniff The Sky

- Don't burn yourself out
- Count how many files follow the pattern: `ls */*.txt | wc -l`
- [csvkit](https://csvkit.readthedocs.io/en/latest/): command-line tools for converting to and working with CSV, such as:
  - in2csv: convert * to CSV
  - csvcut -n: print column names
  - csvsql: import into PostgreSQL (remember to replace varchar to text)

> csvsql my_csv_path -i postgresql --tables "import.my_name" --noconstraints –overwrite | sed 's/VARCHAR/text/g' > import.sql

- Using `cut` command to retrieve the desired columns: `cut -d ';' -f 1-2,4-6  user_data/cigarros.csv`
- CTE (Common Table Expression): `with temp_table_name as ( select ...), other_name as (select ... where temp_table_name.x = 2) select * from other_name`

```sql
with count_events as (select count(*) from events),
     count_regions as (select count(*) from regions)
select * from count_events, count_regions;
```

## Ring Dust
- PostgreSQL support the following languages: PL/pgSQL, PL/Tcl, PL/Perl, and PL/Python.

```sql
drop function if exists my_function(arguments_types);
create function my_function (arguments)
returns return_datatype
IMMUTABLE -- if pure function (no side effects, same input same output)
as $$
   declare
      ...
   begin
      ...
      return my_return_value
   end;
$$ language sql;
```
Or similar to the one presented in the book

```sql
drop function if exists max_price_per_region(int);
create function max_price_per_region(rid int, out numeric)
as $$
    select max(price) from events where events.region_id=rid
    -- implicity return the first row of this select
$$ language sql;
```

To other languages, such as python, it is necessary to run `CREATE LANGUAGE [plpython3u]` that requires installing python itself along with Postgres.

- Window function: similar to aggregation without gruping rows `count(1) over (partition by ...)` (you may want to add `distinct` in after the `select`)

as example, the percentage of entries per year with max/min price per year.

```sql
select distinct
    year,
    round(100.0 * (count(1) over (partition by year)::numeric
            / (count(1) over())::numeric), 2) as percentage_of_entries,
    (max(price) over (partition by year)::numeric
            / (count(1) over())::numeric) as max_price,
    (min(price) over (partition by year)::numeric
            / (count(1) over())::numeric) as min_price
from events;
```

## A Tight Ship

- Chapter dedicated to explaining 'why to choose postgres'
- [PostgreSQL License](https://www.postgresql.org/about/licence/): liberal Open Source license, similar to the BSD or MIT licenses. [You can distribute, modify and commercial use](https://www.tldrlegal.com/license/postgresql-license-postgresql).
- Price per hour comparison on AWS-RDS with db.t3.xlarge (16GB, 4vCPU): $0.60 [oracle](https://aws.amazon.com/rds/oracle/pricing/) vs $0.29 [Postgres](https://aws.amazon.com/rds/postgresql/pricing/)
- [MVCC](https://www.postgresql.org/docs/7.1/mvcc.html) (Multi-Version Concurrency Control): locks acquired for querying (reading) data don't conflict with locks acquired for writing data. (reading doesn't blocks writing, and writing doesn't blocks reading).
- For writing: the data is lifted into virtual memory, only when the transaction is complete is the entire change written to disk in one operation.
---

[^1]: Some notes here were not directly found in the book, but the book led me to research about.

[^2]: Data From: https://dados.gov.br/dados/conjuntos-dados/destinacoes-de-mercadorias-apreendidas

[^3]: I would like to thank to [Giovanni](https://giovannipcarvalho.github.io/2023/04/03/postgresql-and-psql-in-docker.html) for the psql script.
