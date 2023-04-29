-- Lookup Tables
drop table if exists regions cascade;

select distinct
    (region) as description into regions
from
    import.cigarettes;

alter table regions add id serial primary key;

-- convert functions
drop function if exists br_month_to_int(text);
create function br_month_to_int(month text)
RETURNS int
IMMUTABLE
AS $$
BEGIN
    case month
    when 'Janeiro' then return 1;
    when 'Fevereiro' then return 2;
    when 'Março' then return 3;
    when 'Abril' then return 4;
    when 'Maio' then return 5;
    when 'Junho' then return 6;
    when 'Julho' then return 7;
    when 'Agosto' then return 8;
    when 'Setembro' then return 9;
    when 'Outubro' then return 10;
    when 'Novembro' then return 11;
    when 'Dezembro' then return 12;
    END CASE;
END;
$$
language plpgsql;


drop table if exists events;
create table
    events (
        id serial primary key,
        year int,
        month int,
        rf text,
        region_id int references regions (id),
        price numeric
    );

insert into events(year, month, rf, region_id, price)
select
    cigar.year::int,
    br_month_to_int(cigar.month),
    cigar.rf,
    regions.id,
    replace(cigar.price, ',', '.')::numeric
from import.cigarettes cigar
left join regions
    on cigar.region = regions.description;
