SELECT get_the_most_dangerous();

SELECT
    targets.enemy_id AS enemy_id,
    SUM(defense_objects_types.importance * SQRT((targets.x - defense_objects.x) * (targets.x - defense_objects.x) + (targets.y - defense_objects.y) * (targets.y - defense_objects.y))) AS danger
FROM targets, defense_objects
INNER JOIN defense_objects_types
ON defense_objects_types.defense_object_type_id = defense_objects.defense_object_type_id 
GROUP BY targets.enemy_id
ORDER BY danger DESC;
