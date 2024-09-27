-- auto-generated definition
create table user
(
    user_id            int auto_increment
        primary key,
    email              varchar(256) not null,
    password           varchar(256) not null,
    created_date       timestamp    not null,
    last_modified_date timestamp    not null,
    constraint email
        unique (email)
);

