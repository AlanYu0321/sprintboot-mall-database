create
    definer = root@localhost procedure SP_GET_PRODUCT_BY_ID(IN i_product_id int)
BEGIN
    SELECT *
    FROM product
    WHERE product_id = i_product_id;

END;

