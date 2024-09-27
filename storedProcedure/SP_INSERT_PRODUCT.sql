create
    definer = root@localhost procedure SP_INSERT_PRODUCT(IN i_product_name varchar(128),
                                                         IN i_category varchar(32),
                                                         IN i_image_url varchar(256),
                                                         IN i_price int, IN i_stock int,
                                                         IN i_description varchar(1024),
                                                         OUT o_product_id int)
BEGIN
    INSERT INTO product (product_name, category, image_url, price, stock, description, created_date,
                         last_modified_date)
    VALUES (i_product_name, i_category, i_image_url, i_price, i_stock, i_description, CURRENT_TIMESTAMP(),
            CURRENT_TIMESTAMP());

    SET o_product_id = LAST_INSERT_ID();
END;

