create or replace warehouse dev initially_suspended=true;
commit;

use warehouse dev;
commit;

create or replace database dev;

use database dev;

create or replace schema stg_users_posts;
create or replace schema users_posts;

use schema stg_users_posts;

create or replace transient table stg_posts
(VDT variant);

create or replace transient table stg_users
(VDT variant);
commit;


create or replace file format my_json_format
type='json'
strip_outer_array = true;

create or replace temporary stage
json_temp_int_stage
file_format = my_json_format;

/* Not supported in UI
PUT file://C:\Yuan\Downloads\posts.json
@json_temp_init_stage;

PUT file://C:\Yuan\Downloads\users.json
@json_temp_init_stage; 

copy into stg_users
  from
@json_temp_int_stage/users.json
on_error = 'skip_file';

copy into stg_posts
from
@json_temp_int_stage/posts.json
on_error = 'skip_file';

*/

use schema users_posts;
commit;

create or replace table users
(
   id number(38,0),
   name varchar(200),
   username varchar(100),
   email varchar(100),
   addr_line_1 varchar(500),
   addr_line_2 varchar(500),
   city varchar(100),
   zipcode varchar(100),
   latitude varchar(500),
   longitude varchar(500),
   phone varchar(100),
   website varchar(200),
   company_name varchar(100),
   company_catch_phrase varchar(500),
   company_b_s varchar(500)
);
commit;

create or replace table posts
(
   post_id number(38,0),
   user_id number(38,0),
   post_title varchar(500),
   post_body varchar(5000)
);
commit;

insert into posts
(
  select vdt:id as post_id,
         vdt:userId as user_id,
         vdt:title::string as post_title,
         vdt:body::string as post_body
    from stg_users_posts.stg_posts
);
commit;



insert into users
(
   select vdt:id as id,
          vdt:name::string as name,
          vdt:username::string as username,
          vdt:email::string as email,
          vdt:address:street::string as addr_line_1,
          vdt:address:suite::string as addr_line_2,
          vdt:address:city::string as city,
          vdt:address:zipcode::string as zipcode,
          vdt:address:geo:lat::string as latitude,
          vdt:address:geo:lng::string as longitude,
          vdt:phone::string as phone,
          vdt:website::string as website,
          vdt:company:name::string as company_name,
          vdt:company:catchPhrase::string as company_catch_phrase,
          vdt:company:bs::string as company_b_s
     from stg_users_posts.stg_users
);
commit;