drop schema if exists import cascade;

create schema import;

create table
    import.cigarettes (
        year text,
        month text,
        rf text,
        region text,
        price text
    );
