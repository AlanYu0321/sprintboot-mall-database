DROP PROCEDURE IF EXISTS SP_UPDATE_PRODUCT;
create
    definer = root@localhost procedure SP_UPDATE_PRODUCT(IN i_product_id varchar(6),
                                                         IN i_product_name varchar(128),
                                                         IN i_category varchar(32),
                                                         IN i_image_url varchar(256),
                                                         IN i_price int, IN i_stock int,
                                                         IN i_description varchar(1024))
BEGIN

    UPDATE product
    SET product_name       = i_product_name,
        category           = i_category,
        image_url          = i_image_url,
        price              = i_price,
        stock              = i_stock,
        description        = i_description,
        last_modified_date = CURRENT_TIMESTAMP()
    WHERE product_id = i_product_id;

    SELECT *
    FROM product
    WHERE product_id = i_product_id;
END;

