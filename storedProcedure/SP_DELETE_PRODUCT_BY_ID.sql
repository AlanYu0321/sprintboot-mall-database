create
    definer = root@localhost procedure SP_DELETE_PRODUCT_BY_ID(IN i_product_id int)
BEGIN
    DELETE
    FROM product
    WHERE product_id = i_product_id;

END;

