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

```
make clean && make
```

---

[^1]: I would like to thank to [Giovanni](https://giovannipcarvalho.github.io/2023/04/03/postgresql-and-psql-in-docker.html) for the psql script.

[^2]: Data From: https://dados.gov.br/dados/conjuntos-dados/destinacoes-de-mercadorias-apreendidas
