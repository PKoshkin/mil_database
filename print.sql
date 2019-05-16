SELECT get_the_most_dangerous();

SELECT
    targets.enemy_id AS enemy_id,
    targets.height AS height,
    weapon_types.weapon_type_name AS name,
    distance(weapons.x, targets.x, weapons.y, targets.y) AS distance,
    weapon_types.max_height,
    weapon_types.min_height,
    weapon_types.distance_range
FROM targets, weapons
INNER JOIN weapon_types
ON weapon_types.weapon_type_id = weapons.weapon_type_id
WHERE (distance(weapons.x, targets.x, weapons.y, targets.y) < weapon_types.distance_range) AND (targets.height <= weapon_types.max_height) AND (targets.height >= weapon_types.min_height)
ORDER BY enemy_id;
