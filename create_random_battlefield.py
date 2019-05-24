import numpy as np


HALF_SIZE = 20
MIN_HEIGHT = 0
MAX_HEIGHT = 10
MIN_VELOCITY = 100
MAX_VELOCITY = 1100
N_OBJECTS = 300
NAMES = [
    "Иван",
    "Василий",
    "Петр",
    "Владислав",
    "Алексей",
    "Николай",
    "Евгений",
    "Павел",
    "Александр"
]
SURNAMES = [
    "Иванов",
    "Васильев",
    "Петров",
    "Владиславов",
    "Алексеев",
    "Николаев",
    "Евгеньев",
    "Павлов",
    "Александров",
    "Кваченко"
]


def make_target(x, y, height, velocity_x, velocity_y, handler):
    template = "INSERT INTO targets (x, y, height, velocity_x, velocity_y) VALUES ({}, {}, {}, {}, {});"
    print(template.format(x, y, height, velocity_x, velocity_y), file=handler)


def make_weapon(weapon_type_id, charge, x, y, commander_id):
    template = "INSERT INTO weapons (weapon_type_id, charge, x, y, commander_id) VALUES ({}, {}, {}, {}, {});"
    print(template.format(weapon_type_id, charge, x, y, commander_id), file=handler)


def make_defense_object(defense_object_type_id, x, y):
    template = "INSERT INTO defense_objects (defense_object_type_id, x, y) VALUES ({}, {}, {});"
    print(template.format(defense_object_type_id, x, y), file=handler)


def make_commander(name, surname, age):
    template = "INSERT INTO commanders (name, surname, age) VALUES ('{}', '{}', {});"
    print(template.format(name, surname, age), file=handler)


def make_commanders(number, handler):
    names = np.random.choice(NAMES, size=number)
    surnames = np.random.choice(SURNAMES, size=number)
    ages = np.random.randint(18, 50, size=number)
    for name, surname, age in zip(names, surnames, ages):
        make_commander(name, surname, age)


def make_targets(number, handler):
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    heights = np.random.uniform(MIN_HEIGHT, MAX_HEIGHT, number)
    velocity_norm = np.random.uniform(MIN_VELOCITY, MAX_VELOCITY, number)
    velocity_angle = np.random.uniform(0, 2 * np.pi, number)
    velocity_xs = velocity_norm * np.cos(velocity_angle)
    velocity_ys = velocity_norm * np.sin(velocity_angle)
    for x, y, height, velocity_x, velocity_y in zip(xs, ys, heights, velocity_xs, velocity_ys):
        make_target(x, y, height, velocity_x, velocity_y, handler)


def make_weapons(number, handler):
    weapon_id_to_max_charge = {
        1: 12,
        2: 100,
        3: 1000,
        4: 16
    }
    weapon_type_ids = np.random.randint(min(weapon_id_to_max_charge), max(weapon_id_to_max_charge) + 1, number)
    charges = list(map(lambda weapon_id: weapon_id_to_max_charge[weapon_id], weapon_type_ids))
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    for i, (weapon_type_id, charge, x, y) in enumerate(zip(weapon_type_ids, charges, xs, ys)):
        make_weapon(weapon_type_id, charge, x, y, i + 1)


def make_defense_objects(number, handler):
    xs = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    ys = np.random.uniform(-HALF_SIZE, HALF_SIZE, number)
    defense_object_type_ids = np.random.randint(1, 4, number)
    for defense_object_type_id, x, y in zip(defense_object_type_ids, xs, ys):
        make_defense_object(defense_object_type_id, x, y)


if __name__ == "__main__":
    with open("create_battlefield.sql", "w") as handler:
        #make_targets(N_OBJECTS, handler)
        make_defense_objects(N_OBJECTS, handler)
        make_commanders(N_OBJECTS, handler);
        make_weapons(N_OBJECTS, handler)
        #make_targets(N_OBJECTS, handler)
