-- auto-generated definition
create table product
(
    product_id         int auto_increment
        primary key,
    product_name       varchar(128)  not null,
    category           varchar(32)   not null,
    image_url          varchar(256)  not null,
    price              int           not null,
    stock              int           not null,
    description        varchar(1024) null,
    created_date       timestamp     not null,
    last_modified_date timestamp     not null
);

