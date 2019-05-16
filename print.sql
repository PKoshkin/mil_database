SELECT get_the_most_dangerous();

SELECT
    targets.enemy_id AS enemy_id,
    targets.x AS x,
    targets.y AS y,
    weapon_types.weapon_type_name AS name,
    weapons.x AS weapon_x,
    weapons.y AS weapon_y
FROM targets, weapons
INNER JOIN weapon_types
ON weapon_types.weapon_type_id = weapons.weapon_type_id
WHERE targets.enemy_id = 7;
