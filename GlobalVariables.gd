extends Node

var input_num:int = 6

var output_num:int = 2

var orig_plant_energy:int = 1000000

var orig_animal_energy:int = 100000

var map_width:int = 36000

var map_height:int = 23000

var initial_animal_spawn_number:int = 100

var initial_plant_spawn_number:int = 0

var paused:bool = true

var border_width:int = 2000

var min_animal_number:int = 50

var max_damage_capability:int = 2000

var linear_speed_multiplier:float = 20.0 # inc by *60 since multiplying by delta

var rotational_speed_multiplier:float = 500.0

var offset_from_parent:int = 50

var orig_animal_health = 10000

var max_activation_time = 20

var plant_spawn_distance_multiplier:float = 250.0

enum Plant_spawn {PERLIN=0, NEAR_EXISTING=1, NEAR_DELETED=2}
enum Animal_spawn {PERLIN=0, NEAR_EXISTING_ANIMAL=1, NEAR_EXISTING_PLANT=2}

var plant_spawn_type = Plant_spawn.NEAR_DELETED
var animal_spawn_type = Animal_spawn.NEAR_EXISTING_PLANT
