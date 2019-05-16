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


--create tables
CREATE TABLE targets (
    enemy_id SERIAL NOT NULL,
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
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
    x DECIMAL NOT NULL,
    y DECIMAL NOT NULL,
    max_charge INTEGER NOT NULL,
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


--functions
--CREATE FUNCTION calculate_danger(INTEGER) RETURNS DECIMAL AS '
--DECLARE
--    result DECIMAL;
--BEGIN
--    SELECT danger INTO result
--    ...
--    RETURN result;
--END;
--' LANGUAGE plpgsql;
