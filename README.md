# sprintboot-mall-database

SQL DDL and stored procedures for the Spring Boot “mall” project. This repo is the **database layer only** (tables + procedures). Use it together with your Spring Boot application (service/API) repo.

> Folders:
>
> - `table/` — table creation & related DDL
> 
> - `storedProcedure/` — stored procedures and database-side logic
>
> *(See file names inside each folder for the exact objects.)*

---

## 📦 What this includes
- Schema & table definitions for the mall domain (products, orders, users, etc.—see `table/`).
- Stored procedures for common business operations (e.g., inventory updates, order placement—see `storedProcedure/`).
- Drop/recreate patterns for local development.

> Exact object names can be seen in the SQL files; this README focuses on **how to run** them reliably.

## 🧰 Prerequisites
- **MySQL** 8.0+ (or MariaDB 10.5+) recommended
- A MySQL user with privileges to create schemas, tables, procedures
- Optional GUI: **MySQL Workbench** / **DBeaver**

### Import via MySQL Workbench (GUI)
1. Open **Workbench** → connect to your server.
2. Create schema `mall` (utf8mb4, collate utf8mb4_0900_ai_ci).
3. File → Run SQL Script → select `table/*.sql` in order, then `storedProcedure/*.sql`.
4. Execute; verify objects in **Schemas** panel.

## 🧱 Foreign keys & dummy rows (DW‑style, optional)
If you mirror analytics patterns (e.g., fact tables), add a **dummy row** with key `-1` and `COALESCE` to handle missing dimension references. Example:
```sql
-- dummy row example
INSERT INTO dim_product (product_skey, product_name, is_active)
VALUES (-1, 'UNKNOWN', 0);

-- when loading facts
INSERT INTO fact_sales (..., product_skey, ...)
SELECT ..., COALESCE(p.product_skey, -1) AS product_skey, ...
FROM stg_sales s
LEFT JOIN dim_product p ON p.product_id = s.product_id;
```

## 🧭 Stored procedure patterns
Typical procedure concerns you might see or add:
- **Inventory safety:** decrement stock atomically within a transaction; prevent negative inventory.
- **Order placement:** create order header + lines + reserve stock; rollback on failure.
- **Idempotency tokens:** avoid duplicate orders on retry.
- **Audit columns:** `created_at`, `updated_at`, `created_by`, etc.

Skeleton:
```sql
DELIMITER //
CREATE PROCEDURE sp_place_order(IN p_user_id BIGINT, IN p_json TEXT)
BEGIN
  DECLARE exit handler FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  -- TODO: parse items, insert order header/lines, update stock
  COMMIT;
END //
DELIMITER ;
```
