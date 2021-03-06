--drop users
DROP USER IF EXISTS reader1;
DROP USER IF EXISTS reader2;
DROP USER IF EXISTS writer1;
DROP USER IF EXISTS writer2;


--delete foreign keys
ALTER TABLE IF EXISTS weapons DROP CONSTRAINT IF EXISTS weapons_fk1;
ALTER TABLE IF EXISTS weapons DROP CONSTRAINT IF EXISTS weapons_fk2;
ALTER TABLE IF EXISTS defense_objects DROP CONSTRAINT IF EXISTS defense_objects_fk;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS orders_fk1;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS orders_fk2;


--drop views
DROP VIEW IF EXISTS possible_shots;
DROP VIEW IF EXISTS targets_with_danger;
DROP VIEW IF EXISTS charge_stocks;
DROP VIEW IF EXISTS defense_objects_in_danger;
DROP VIEW IF EXISTS weapons_types_statistics;


--drop triggers
--DROP TRIGGER IF EXISTS DELETE_ORDER_ON_TARGET_DESTROY ON targets;


--drop tables
DROP TABLE IF EXISTS targets;
DROP TABLE IF EXISTS weapons;
DROP TABLE IF EXISTS weapon_types;
DROP TABLE IF EXISTS defense_objects;
DROP TABLE IF EXISTS defense_objects_types;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS commanders ;


--drop functions
DROP FUNCTION IF EXISTS norm(DECIMAL, DECIMAL);
DROP FUNCTION IF EXISTS distance(DECIMAL, DECIMAL, DECIMAL, DECIMAL);
DROP FUNCTION IF EXISTS attack_enemy(INTEGER);
DROP FUNCTION IF EXISTS attack_new_enemy();
DROP FUNCTION IF EXISTS get_the_most_dangerous();
DROP FUNCTION IF EXISTS attack_the_most_dangerous();
DROP FUNCTION IF EXISTS execute_orders();


--drop groups
DROP GROUP IF EXISTS readers;
DROP GROUP IF EXISTS writers;

--create users
CREATE GROUP readers;
CREATE GROUP writers;

CREATE USER reader1 WITH PASSWORD 'reader1';
CREATE USER reader2 WITH PASSWORD 'reader2';

CREATE USER writer1 WITH PASSWORD 'writer1';
CREATE USER writer2 WITH PASSWORD 'writer2';

ALTER GROUP readers ADD USER reader1, reader2;
ALTER GROUP writers ADD USER writer1, writer2;


--create tables
CREATE TABLE targets (
    enemy_id SERIAL NOT NULL,
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    height DECIMAL NOT NULL CHECK (height >= 0),
    velocity_x DECIMAL NOT NULL,
    velocity_y DECIMAL NOT NULL,
    CONSTRAINT targets_pk PRIMARY KEY (enemy_id)
);
CREATE TABLE weapons (
    weapon_id SERIAL NOT NULL,
    weapon_type_id INTEGER NOT NULL,
    commander_id INTEGER NOT NULL UNIQUE,
    charge INTEGER NOT NULL CHECK (charge >= 0),
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    CONSTRAINT weapons_pk PRIMARY KEY (weapon_id)
);
CREATE TABLE weapon_types (
    weapon_type_id SERIAL NOT NULL,
    distance_range DECIMAL NOT NULL CHECK (distance_range >= 0),
    max_height DECIMAL NOT NULL CHECK (max_height >= 0),
    min_height DECIMAL NOT NULL CHECK (min_height >= 0),
    max_charge INTEGER NOT NULL CHECK (max_charge >= 0),
    max_velocity DECIMAL NOT NULL CHECK (max_velocity >= 0),
    weapon_type_name varchar(100) NOT NULL UNIQUE,
    CONSTRAINT weapon_types_pk PRIMARY KEY (weapon_type_id),
    CHECK (max_height >= min_height)
);
CREATE TABLE defense_objects (
    defense_object_id SERIAL NOT NULL,
    defense_object_type_id INTEGER NOT NULL,
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    CONSTRAINT defense_objects_pk PRIMARY KEY (defense_object_id)
);
CREATE TABLE defense_objects_types (
    defense_object_type_id SERIAL NOT NULL,
    importance DECIMAL NOT NULL,
    defense_object_type_name varchar(100) NOT NULL UNIQUE,
    CONSTRAINT defense_objects_types_pk PRIMARY KEY (defense_object_type_id)
);
CREATE TABLE orders (
    order_id SERIAL NOT NULL,
    enemy_id INTEGER NOT NULL UNIQUE,
    weapon_id INTEGER NOT NULL UNIQUE,
    CONSTRAINT orders_pk PRIMARY KEY (order_id)
);
CREATE TABLE commanders (
    commander_id SERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 18),
    CONSTRAINT commanders_pk PRIMARY KEY (commander_id)
);


--revoke grants
REVOKE ALL PRIVILEGES ON TABLE targets FROM GROUP writers;
REVOKE ALL PRIVILEGES ON TABLE weapons FROM GROUP writers;
REVOKE ALL PRIVILEGES ON TABLE weapon_types FROM GROUP writers;
REVOKE ALL PRIVILEGES ON TABLE defense_objects FROM GROUP writers;
REVOKE ALL PRIVILEGES ON TABLE defense_objects_types FROM GROUP writers;
REVOKE ALL PRIVILEGES ON TABLE orders FROM GROUP writers;

REVOKE ALL PRIVILEGES ON TABLE targets FROM GROUP readers;
REVOKE ALL PRIVILEGES ON TABLE weapons FROM GROUP readers;
REVOKE ALL PRIVILEGES ON TABLE weapon_types FROM GROUP readers;
REVOKE ALL PRIVILEGES ON TABLE defense_objects FROM GROUP readers;
REVOKE ALL PRIVILEGES ON TABLE defense_objects_types FROM GROUP readers;
REVOKE ALL PRIVILEGES ON TABLE orders FROM GROUP readers;


 --create foreign keys
ALTER TABLE weapons ADD CONSTRAINT weapons_fk1 FOREIGN KEY (weapon_type_id) REFERENCES weapon_types(weapon_type_id);
ALTER TABLE weapons ADD CONSTRAINT weapons_fk2 FOREIGN KEY (commander_id) REFERENCES commanders(commander_id);
ALTER TABLE defense_objects ADD CONSTRAINT defense_objects_fk FOREIGN KEY (defense_object_type_id) REFERENCES defense_objects_types(defense_object_type_id);
ALTER TABLE orders ADD CONSTRAINT orders_fk1 FOREIGN KEY (enemy_id) REFERENCES targets(enemy_id) ON DELETE CASCADE;
ALTER TABLE orders ADD CONSTRAINT orders_fk2 FOREIGN KEY (weapon_id) REFERENCES weapons(weapon_id) ON DELETE RESTRICT;


--insert values to constant tables
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (70.0, 35.0, 0.015, 12, 3000.0, 'Бук M3');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (8.0, 3.5, 0.0, 100, 600.0, 'Тунгуска');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (4.2, 2.0, 0.0, 1000, 300.0, 'Стрела 1');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (16.0, 10.0, 0.01, 16, 1000.0, 'Тор М2ДТ');

INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (1.0, 'Жилой дом');
INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (10.0, 'КП');
INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (100.0, 'АЭС');


--functions
CREATE FUNCTION norm(DECIMAL, DECIMAL) RETURNS DECIMAL AS '
DECLARE
    result DECIMAL;
BEGIN
    SELECT SQRT($1 * $1 + $2 * $2) INTO result;
    RETURN result;
END;
' LANGUAGE plpgsql;

CREATE FUNCTION distance(DECIMAL, DECIMAL, DECIMAL, DECIMAL) RETURNS DECIMAL AS '
DECLARE
    result DECIMAL;
BEGIN
    SELECT norm($1 - $2, $3 - $4) INTO result;
    RETURN result;
END;
' LANGUAGE plpgsql;

CREATE FUNCTION get_the_most_dangerous() RETURNS INTEGER AS '
DECLARE
    result INTEGER;
BEGIN
    SELECT enemy_id INTO result
    FROM (
        SELECT
            enemy_id
        FROM targets_with_danger
        LIMIT 1
    ) AS tmp;
    RETURN result;
END;
' LANGUAGE plpgsql;

CREATE FUNCTION attack_enemy(INTEGER) RETURNS VOID AS'
DECLARE

BEGIN
    INSERT INTO orders (enemy_id, weapon_id)
    SELECT enemy_id, weapon_id
    FROM (
        SELECT
            targets.enemy_id AS enemy_id,
            weapons.weapon_id AS weapon_id,
            distance(weapons.x, targets.x, weapons.y, targets.y) AS distance
        FROM targets, weapons
        INNER JOIN weapon_types
        ON weapon_types.weapon_type_id = weapons.weapon_type_id
        WHERE (distance(weapons.x, targets.x, weapons.y, targets.y) < weapon_types.distance_range)
            AND (targets.height <= weapon_types.max_height)
            AND (targets.height >= weapon_types.min_height)
            AND (norm(targets.velocity_x, targets.velocity_y) < weapon_types.max_velocity)
            AND weapons.weapon_id NOT IN (SELECT weapon_id FROM orders)
            AND weapons.charge > 0
            AND targets.enemy_id NOT IN (SELECT enemy_id FROM orders)
            AND targets.enemy_id = $1
        ORDER BY distance
        LIMIT 1
    ) AS tmp;
END;
' LANGUAGE plpgsql;

CREATE FUNCTION attack_the_most_dangerous() RETURNS VOID AS'
DECLARE
    the_most_dangerous INTEGER;
BEGIN

    SELECT get_the_most_dangerous() INTO the_most_dangerous;
    PERFORM attack_enemy(the_most_dangerous);
END;
' LANGUAGE plpgsql;

CREATE FUNCTION execute_orders() RETURNS VOID AS'
DECLARE

BEGIN
    UPDATE
        weapons
    SET
        charge = charge - 1
    FROM
        orders
    WHERE orders.weapon_id = weapons.weapon_id;

    DELETE FROM targets
    WHERE enemy_id IN (SELECT enemy_id FROM orders);
END;
' LANGUAGE plpgsql;

CREATE FUNCTION attack_new_enemy() RETURNS TRIGGER AS'
DECLARE
BEGIN
    PERFORM attack_enemy(NEW.enemy_id);
    PERFORM execute_orders();
    RETURN NEW;
END;
' LANGUAGE plpgsql;


--views
CREATE VIEW possible_shots AS
SELECT
    targets.enemy_id AS enemy_id,
    weapon_types.weapon_type_name AS weapon_type,
    weapons.weapon_id AS weapon_id,
    distance(weapons.x, targets.x, weapons.y, targets.y) AS distance
FROM targets, weapons
INNER JOIN weapon_types
ON weapon_types.weapon_type_id = weapons.weapon_type_id
WHERE (distance(weapons.x, targets.x, weapons.y, targets.y) < weapon_types.distance_range)
    AND (targets.height <= weapon_types.max_height)
    AND (targets.height >= weapon_types.min_height)
    AND (norm(targets.velocity_x, targets.velocity_y) < weapon_types.max_velocity)
    AND weapons.weapon_id NOT IN (SELECT weapon_id FROM orders)
    AND weapons.charge > 0
    AND targets.enemy_id NOT IN (SELECT enemy_id FROM orders)
ORDER BY targets.enemy_id;

CREATE VIEW targets_with_danger AS
SELECT
    targets.enemy_id AS enemy_id,
    SUM(defense_objects_types.importance * distance(targets.x, defense_objects.x, targets.y, defense_objects.y)) AS danger
FROM targets, defense_objects
INNER JOIN defense_objects_types
ON defense_objects_types.defense_object_type_id = defense_objects.defense_object_type_id 
GROUP BY targets.enemy_id
HAVING enemy_id NOT IN (SELECT enemy_id FROM orders)
ORDER BY danger DESC;

CREATE VIEW charge_stocks AS
SELECT
    weapon_types.weapon_type_name AS weapon_type,
    weapons.charge AS charge
FROM weapons
INNER JOIN weapon_types
ON weapon_types.weapon_type_id = weapons.weapon_type_id
ORDER BY weapons.charge;

CREATE VIEW defense_objects_in_danger AS
SELECT
    defense_objects.defense_object_id AS defense_object_id,
    defense_objects_types.defense_object_type_name AS name,
    SUM(defense_objects_types.importance * distance(targets.x, defense_objects.x, targets.y, defense_objects.y)) AS danger
FROM targets, defense_objects
INNER JOIN defense_objects_types
ON defense_objects_types.defense_object_type_id = defense_objects.defense_object_type_id 
WHERE targets.enemy_id NOT IN (SELECT enemy_id FROM orders)
GROUP BY defense_objects.defense_object_id, defense_objects_types.defense_object_type_name 
ORDER BY danger DESC;

CREATE VIEW weapons_types_statistics AS
SELECT
    weapon_types.weapon_type_name AS weapon_type,
    COUNT(*) AS counter
FROM weapons
INNER JOIN weapon_types
ON weapon_types.weapon_type_id = weapons.weapon_type_id
GROUP BY weapon_types.weapon_type_id
ORDER BY counter DESC;

--trigers
CREATE TRIGGER ATTACK_NEW_TARGET AFTER INSERT ON targets FOR EACH ROW EXECUTE PROCEDURE attack_new_enemy();


--grants
GRANT INSERT, UPDATE, DELETE ON TABLE targets TO GROUP writers;
GRANT INSERT, UPDATE, DELETE ON TABLE weapons TO GROUP writers;
GRANT INSERT, UPDATE, DELETE ON TABLE weapon_types TO GROUP writers;
GRANT INSERT, UPDATE, DELETE ON TABLE defense_objects TO GROUP writers;
GRANT INSERT, UPDATE, DELETE ON TABLE defense_objects_types TO GROUP writers;
GRANT INSERT, UPDATE, DELETE ON TABLE orders TO GROUP writers;

GRANT SELECT ON TABLE targets TO GROUP readers;
GRANT SELECT ON TABLE weapons TO GROUP readers;
GRANT SELECT ON TABLE weapon_types TO GROUP readers;
GRANT SELECT ON TABLE defense_objects TO GROUP readers;
GRANT SELECT ON TABLE defense_objects_types TO GROUP readers;
GRANT SELECT ON TABLE orders TO GROUP readers;
