SELECT get_the_most_dangerous();

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
ORDER BY enemy_id;
