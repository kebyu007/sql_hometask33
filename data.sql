CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    price NUMERIC(10,2),
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (name, email)
SELECT 
    'User ' || i,
    'user' || i || '@gmail.com'
FROM generate_series(1,50) AS s(i);


INSERT INTO products (name, price, user_id)
SELECT
    'Product ' || i,
    ROUND((RANDOM() * 1000)::numeric, 2),
    FLOOR(RANDOM() * 50 + 1)::int
FROM generate_series(1,1000) AS s(i);

SELECT * FROM USERS LIMIT 10;

SELECT * FROM products LIMIT 10;

-- 1. Eng koâ€˜p mahsulot qoâ€˜shgan foydalanuvchini aniqlash. Bunda user_id, user_name va total_products (mahsulotlari soni) qaytsin

SELECT 
    u.id,
    u.name,
    COUNT(p.id) AS total_products
FROM users u
JOIN products p ON u.id=p.user_id
GROUP BY u.id, u.name
HAVING COUNT(p.id) = (
    SELECT MAX(product_count)
    FROM (
        SELECT COUNT(*) AS product_count
        FROM products
        GROUP BY user_id
    ) t
);

-- 2. Har bir foydalanuvchining eng qimmat mahsulotini topish. Bunda user_id, user_name, product_name va price kelsin

SELECT 
    u.id AS user_id,
    u.name AS user_name,
    p.name AS product_name,
    price
FROM users u
JOIN products p ON u.id=p.user_id
WHERE p.price = (
    SELECT MAX(price)
    FROM products
    WHERE user_id = p.user_id
)
LIMIT 10;

-- 3. Eng arzon mahsulotni sotgan foydalanuvchini aniqlash. Bunda user_id, user_name, product_name va price kelsin.

SELECT
    u.id AS user_id,
    u.name AS user_name,
    p.name AS product_name,
    price
FROM users u
JOIN products p ON u.id=p.user_id
WHERE p.price = (
    SELECT MIN(price)
    FROM products
)
LIMIT 10;

-- 4. 3ta har xil ismli (Tom, Alex, Jimi) userlar yaratish va ularga read_only, write_only, admin_access(barcha ruhsatlarga ega) bo'lgan rollarni har biriga bittadan biriktiring

CREATE USER Tom WITH PASSWORD '123';
CREATE USER Alex WITH PASSWORD '345';
CREATE USER Jimi WITH PASSWORD '567';

CREATE ROLE read_only;
CREATE ROLE write_only ;
CREATE ROLE admin_access;

GRANT read_only TO Tom;
GRANT write_only TO Alex;
GRANT admin_access TO Jimi;

ALTER ROLE admin_access WITH SUPERUSER;


GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO read_only;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA PUBLIC TO write_only;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA PUBLIC TO admin_access;