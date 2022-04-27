create extension plr;
create extension postgis;
select * from pg_extension;

create or replace function view_r_library_paths()
returns text as $$
  print(.libPaths())
$$ language plr;

select view_r_library_paths();