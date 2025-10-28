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

## 🚀 Quick start (CLI)
```bash
# 1) create database (adjust name/charset as needed)
mysql -u root -p -e 'CREATE DATABASE mall DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;'

# 2) load tables first (order matters if there are FKs)
mysql -u root -p mall < table/00_create_tables.sql

# 3) load other objects (indexes, views, seed data if present)
# mysql -u root -p mall < table/10_indexes_views.sql
# mysql -u root -p mall < table/20_seed_data.sql

# 4) load stored procedures
mysql -u root -p mall < storedProcedure/00_procedures.sql
```

### Import via MySQL Workbench (GUI)
1. Open **Workbench** → connect to your server.
2. Create schema `mall` (utf8mb4, collate utf8mb4_0900_ai_ci).
3. File → Run SQL Script → select `table/*.sql` in order, then `storedProcedure/*.sql`.
4. Execute; verify objects in **Schemas** panel.

## 🔗 Spring Boot app configuration (example)
In your Spring Boot **application.yml** (or **application.properties**):
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mall?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8
    username: root
    password: <your-password>
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: validate   # use 'none' or 'validate' when DB is managed by these scripts
    show-sql: true
    properties:
      hibernate.format_sql: true
```

> If your app uses Flyway/Liquibase, point them at `table/` to baseline migrations and keep procedures under version control.

## 🧪 Local dev workflow
```bash
# reset (⚠️ destructive)
mysql -u root -p -e 'DROP DATABASE IF EXISTS mall; CREATE DATABASE mall DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;'
mysql -u root -p mall < table/00_create_tables.sql
mysql -u root -p mall < storedProcedure/00_procedures.sql
```

- Keep **idempotent** scripts when possible.
- Name files with a sortable prefix to enforce execution order, e.g.:
  - `00_create_tables.sql`
  - `10_constraints.sql`
  - `20_seed_data.sql`
  - `90_views.sql`
  - `99_grants.sql`

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

## 🔒 Users & grants (example)
```sql
CREATE USER IF NOT EXISTS 'mall_app'@'%' IDENTIFIED BY 'change_me';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON mall.* TO 'mall_app'@'%';
FLUSH PRIVILEGES;
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

## 🗺️ Roadmap
- [ ] Add sample data for products/categories/users
- [ ] Add integration tests (Testcontainers or Docker Compose) for the Spring Boot app
- [ ] Add Flyway/Liquibase migrations structure
- [ ] Provide ERD (dbdiagram.io or MySQL Workbench reverse‑engineered PNG)

## 🤝 Contributing
1. Fork → feature branch → PR
2. Keep SQL formatted and ordered; include comments at the top of each file:
   - Purpose / dependencies
   - Execution order
   - Parameters & examples (for procedures)

## 📄 License
Add a license (MIT/Apache‑2.0) so others know how they can use these scripts.

## 👤 Author
Maintainer: Alan Yu (`@AlanYu0321`)
```

# End
This README is a generic, safe‑by‑default guide. Update the filenames in the commands to match your actual SQL scripts in `table/` and `storedProcedure/`.
