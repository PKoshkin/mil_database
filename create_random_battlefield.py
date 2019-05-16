import numpy as np


HALF_SIZE = 20
MAX_HEIGHT = 10


def make_target(x, y, height, velocity_x, velocity_y, handler):
    template = "INSERT INTO targets (x, y, height, velocity_x, velocity_y) VALUES ({}, {}, {}, {}, {});"
    print(template.format(x, y, height, velocity_x, velocity_y), file=handler)


def make_weapon(weapon_type_id, charge, x, y):
    template = "INSERT INTO weapons (weapon_type_id, charge, x, y) VALUES ({}, {}, {}, {});"
    print(template.format(weapon_type_id, charge, x, y), file=handler)


def make_defense_object(defense_object_type_id, x, y):
    template = "INSERT INTO defense_objects (defense_object_type_id, x, y) VALUES ({}, {}, {});"
    print(template.format(defense_object_type_id, x, y), file=handler)


def make_targets(number, handler):
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    heights = np.random.uniform(0, MAX_HEIGHT, number)
    velocity_xs = np.random.uniform(100, 2000, number)
    velocity_ys = np.random.uniform(100, 2000, number)
    for x, y, height, velocity_x, velocity_y in zip(xs, ys, heights, velocity_xs, velocity_ys):
        make_target(x, y, height, velocity_x, velocity_y, handler)


def make_weapons(number, handler):
    weapon_id_to_max_charge = {
        1: 12,
        2: 100,
        3: 1000,
        4: 16
    }
    weapon_type_ids = np.random.randint(min(weapon_id_to_max_charge), max(weapon_id_to_max_charge), number)
    charges = list(map(lambda weapon_id: weapon_id_to_max_charge[weapon_id], weapon_type_ids))
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    for weapon_type_id, charge, x, y in zip(weapon_type_ids, charges, xs, ys):
        make_weapon(weapon_type_id, charge, x, y)


def make_defense_objects(number, handler):
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    defense_object_type_ids = np.random.randint(1, 4, number)
    for defense_object_type_id, x, y in zip(defense_object_type_ids, xs, ys):
        make_defense_object(defense_object_type_id, x, y)


if __name__ == "__main__":
    with open("create_battlefield.sql", "w") as handler:
        make_defense_objects(10, handler)
        make_weapons(10, handler)
        make_targets(10, handler)
