--delete foreign keys
ALTER TABLE IF EXISTS weapons DROP CONSTRAINT IF EXISTS weapons_fk;
ALTER TABLE IF EXISTS defense_objects DROP CONSTRAINT IF EXISTS defense_objects_fk;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS orders_fk1;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS orders_fk2;


--drop tables
DROP TABLE IF EXISTS targets;
DROP TABLE IF EXISTS weapons;
DROP TABLE IF EXISTS weapon_types;
DROP TABLE IF EXISTS defense_objects;
DROP TABLE IF EXISTS defense_objects_types;
DROP TABLE IF EXISTS orders;


--drop functions
DROP FUNCTION IF EXISTS get_the_most_dangerous();


--create tables
CREATE TABLE targets (
    enemy_id SERIAL NOT NULL,
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    height DECIMAL NOT NULL,
    velocity_x DECIMAL NOT NULL,
    velocity_y DECIMAL NOT NULL,
    CONSTRAINT targets_pk PRIMARY KEY (enemy_id)
);
CREATE TABLE weapons (
    weapon_id SERIAL NOT NULL,
    weapon_type_id INTEGER NOT NULL,
    charge INTEGER NOT NULL,
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    CONSTRAINT weapons_pk PRIMARY KEY (weapon_id)
);
CREATE TABLE weapon_types (
    weapon_type_id SERIAL NOT NULL,
    distance_range DECIMAL NOT NULL,
    max_height DECIMAL NOT NULL,
    min_height DECIMAL NOT NULL,
    max_charge INTEGER NOT NULL,
    max_velocity DECIMAL NOT NULL,
    weapon_type_name varchar(100) NOT NULL,
    CONSTRAINT weapon_types_pk PRIMARY KEY (weapon_type_id)
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
    defense_object_type_name varchar(100) NOT NULL,
    CONSTRAINT defense_objects_types_pk PRIMARY KEY (defense_object_type_id)
);
CREATE TABLE orders (
    order_id SERIAL NOT NULL,
    enemy_id INTEGER NOT NULL,
    weapon_id INTEGER NOT NULL,
    damage INTEGER NOT NULL,
    CONSTRAINT orders_pk PRIMARY KEY (order_id)
);


 --create foreign keys
ALTER TABLE weapons ADD CONSTRAINT weapons_fk FOREIGN KEY (weapon_type_id) REFERENCES weapon_types(weapon_type_id);
ALTER TABLE defense_objects ADD CONSTRAINT defense_objects_fk FOREIGN KEY (defense_object_type_id) REFERENCES defense_objects_types(defense_object_type_id);
ALTER TABLE orders ADD CONSTRAINT orders_fk1 FOREIGN KEY (enemy_id) REFERENCES targets(enemy_id);
ALTER TABLE orders ADD CONSTRAINT orders_fk2 FOREIGN KEY (weapon_id) REFERENCES weapons(weapon_id);


--insert values to constant tables
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (70.0, 35.0, 0.015, 12, 3000.0, 'Бук M3');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (8.0, 3.5, 0.0, 100, 600.0, 'Тунгуска');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (4.2, 2.0, 0.0, 1000, 300.0, 'Стрела 1');
INSERT INTO weapon_types (distance_range, max_height, min_height, max_charge, max_velocity, weapon_type_name) VALUES (16.0, 10.0, 0.01, 16, 1000.0, 'Тор М2ДТ');

INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (1.0, 'Жилой дом');
INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (10.0, 'КП');
INSERT INTO defense_objects_types (importance, defense_object_type_name) VALUES (100.0, 'АЭС');


--functions
CREATE FUNCTION distance(decimal, decimal, decimal, decimal) RETURNS DECIMAL AS '
DECLARE
    result DECIMAL;
BEGIN
    SELECT SQRT(($1 - $2) * ($1 - $2) + ($3 - $4) * ($3 - $4)) INTO result;
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
            targets.enemy_id AS enemy_id,
            SUM(defense_objects_types.importance * SQRT((targets.x - defense_objects.x) * (targets.x - defense_objects.x) + (targets.y - defense_objects.y) * (targets.y - defense_objects.y))) AS danger
        FROM targets, defense_objects
        INNER JOIN defense_objects_types
        ON defense_objects_types.defense_object_type_id = defense_objects.defense_object_type_id 
        GROUP BY targets.enemy_id
        ORDER BY danger DESC
        LIMIT 1
    ) AS tmp;
    RETURN result;
END;
' LANGUAGE plpgsql;
