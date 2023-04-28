drop schema if exists import cascade;

-- create a schema just for importing the data with text type
create schema import;

create table
    import.cigarettes (
        year text,
        month text,
        rf text,
        region text,
        price text
    );