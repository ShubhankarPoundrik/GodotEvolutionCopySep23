extends Node

export (PackedScene) var animals
export (PackedScene) var plants
export (PackedScene) var kdtree

var num_of_initial_animals_spawned:int = 0
var num_of_plants:int = 0
var free_energy:int = 0
var total_system_energy:int = 0
var animals_added = 0
var perlin_scale:float
var kt = null
var ktAnimal = null
var plant_pos_rand:int = 100
var plant_list = []
var animal_list = []
var gameTime:int = 0

func _ready():
	if GlobalVariables.plant_spawn_type == GlobalVariables.Plant_spawn.PERLIN or GlobalVariables.animal_spawn_type==GlobalVariables.Animal_spawn.PERLIN:
		perlin_scale = max(GlobalVariables.map_width, GlobalVariables.map_height)/100.0
		$PerlinNoiseGen.initialize((GlobalVariables.map_width-200)/perlin_scale , (GlobalVariables.map_height-200)/perlin_scale )
	while num_of_plants < GlobalVariables.initial_plant_spawn_number:
		spawn_plant()
		num_of_plants += 1
	plant_list =  get_tree().get_nodes_in_group("plants_group")
	spawn_initial_animal_batch()
	
	get_tree().paused = GlobalVariables.paused

func spawn_plant():
	randomize()
	var plant = plants.instance()
	add_child(plant)
	if GlobalVariables.plant_spawn_type == GlobalVariables.Plant_spawn.PERLIN:
		var pos = $PerlinNoiseGen.getPerlinPosition() * perlin_scale
		pos.x += 100 + rand_range(-plant_pos_rand,plant_pos_rand)
		pos.y += 100 + rand_range(-plant_pos_rand,plant_pos_rand)
		plant.initialize(pos)
	elif GlobalVariables.plant_spawn_type == GlobalVariables.Plant_spawn.NEAR_EXISTING:
		var pos = Vector2.ZERO
		if len(plant_list) != 0:
			pos = plant_list[randi()%len(plant_list)].position + Vector2(rand_range(-2*plant_pos_rand,2*plant_pos_rand), rand_range(-2*plant_pos_rand,2*plant_pos_rand))
		else:
			pos = Vector2(rand_range(30, GlobalVariables.map_width-30), rand_range(30, GlobalVariables.map_height-30))
		pos.x = clamp(pos.x, 100, GlobalVariables.map_width-100)
		pos.y = clamp(pos.y, 100, GlobalVariables.map_height-100)
		plant.initialize(pos)
	elif GlobalVariables.plant_spawn_type == GlobalVariables.Plant_spawn.NEAR_DELETED:
		var pos = Vector2.ZERO
		if not $Queue.isEmpty():
			pos = $Queue.pop()["val"] + Vector2(rand_range(-2*plant_pos_rand,2*plant_pos_rand), rand_range(-2*plant_pos_rand,2*plant_pos_rand))
		else:
			# Same as NEAR_EXISTING
			if len(plant_list) != 0:
				pos = plant_list[randi()%len(plant_list)].position + Vector2(rand_range(-2*plant_pos_rand,2*plant_pos_rand), rand_range(-2*plant_pos_rand,2*plant_pos_rand))
			else:
				pos = Vector2(rand_range(30, GlobalVariables.map_width-30), rand_range(30, GlobalVariables.map_height-30))	
		pos.x = clamp(pos.x, 100, GlobalVariables.map_width-100)
		pos.y = clamp(pos.y, 100, GlobalVariables.map_height-100)
		plant.initialize(pos)
	else:
		print("Error: Plant spawn type not recognised")
	
func spawn_child_animal(parent_position, nn, genes, props, energy_passed):
	var animal = animals.instance()
	add_child(animal)
	animal.init(parent_position, nn, genes, props, energy_passed)
#	animal_list =  get_tree().get_nodes_in_group("animals_group")
#	print("Input num: ",animal_list[1].get_node("NN").input_num)

func spawn_animal(first_batch = false):
	randomize()
	var animal = animals.instance()
	add_child(animal)
	var pos:Vector2 = Vector2(GlobalVariables.map_width/2, GlobalVariables.map_height/2)
	if GlobalVariables.animal_spawn_type == GlobalVariables.Animal_spawn.PERLIN:
		pos = $PerlinNoiseGen.getPerlinPosition() * perlin_scale
		pos.x += 100 + rand_range(-plant_pos_rand,plant_pos_rand)
		pos.y += 100 + rand_range(-plant_pos_rand,plant_pos_rand)
	elif GlobalVariables.animal_spawn_type == GlobalVariables.Animal_spawn.NEAR_EXISTING_ANIMAL:
		if len(animal_list) == 0:
			pos = Vector2(rand_range(30, GlobalVariables.map_width-30), rand_range(30, GlobalVariables.map_height-30))
		else:
			pos = animal_list[randi()%len(animal_list)].position + Vector2(rand_range(-GlobalVariables.offset_from_parent,GlobalVariables.offset_from_parent), rand_range(-GlobalVariables.offset_from_parent,GlobalVariables.offset_from_parent))
	elif GlobalVariables.animal_spawn_type == GlobalVariables.Animal_spawn.NEAR_EXISTING_PLANT:
		if len(plant_list) != 0:
			pos = plant_list[randi()%len(plant_list)].position + Vector2(rand_range(-plant_pos_rand,plant_pos_rand), rand_range(-plant_pos_rand,plant_pos_rand))
		else:
			pos = Vector2(rand_range(30, GlobalVariables.map_width-30), rand_range(30, GlobalVariables.map_height-30))
	else:
		print("Error: Animal spawn type not recognised")
	pos.x = clamp(pos.x, 30, GlobalVariables.map_width-30)
	pos.y = clamp(pos.y, 30, GlobalVariables.map_height-30)
	if first_batch:
		var offset = Vector2(rand_range(-1,1), rand_range(-1,1))
		offset = offset.normalized() * rand_range(20, GlobalVariables.map_height/5)
		pos.x = GlobalVariables.map_width/2 + offset.x
		pos.y = GlobalVariables.map_height/2 + offset.y
	animal.mutate_first_gen()
	animal.set_pos(pos)
	
func _process(delta):
	# print(Performance.get_monitor(Performance.TIME_FPS))
	animal_list =  get_tree().get_nodes_in_group("animals_group")
	plant_list =  get_tree().get_nodes_in_group("plants_group")
	
	var non_plant_energy:int = free_energy		
	for animal in animal_list:
		non_plant_energy += animal.energy
		
	if free_energy > GlobalVariables.orig_animal_energy and len(animal_list) < GlobalVariables.min_animal_number:
		spawn_animal()
		free_energy -= GlobalVariables.orig_animal_energy
		animals_added += 1	
	while free_energy >= GlobalVariables.orig_plant_energy and non_plant_energy > GlobalVariables.min_animal_number*GlobalVariables.orig_animal_energy+GlobalVariables.orig_plant_energy and len(animal_list) >= GlobalVariables.min_animal_number:
		# non_plant_energy > _ so we preserve enough free energy to spawn animal if animals < min_animal_num
		spawn_plant()
		free_energy -= GlobalVariables.orig_plant_energy
	$CanvasLayer.get_node("DataDisplay").set_text("Initial animals: "+str(GlobalVariables.initial_animal_spawn_number)+", Animals added: "+str(animals_added)+ ", Animal num: "+str(len(animal_list))+", Plant num: "+str(len(plant_list)) + ", Zoom: "+str($Camera2D.zoom_count)+", FPS: "+str(Performance.get_monitor(Performance.TIME_FPS))+", Time: "+str(gameTime))
		
func _on_ChangeAccnTimer_timeout():
	get_tree().call_group("animals_group", "change_accn")

func _on_UpdateEnergyTimer_timeout():
	get_tree().call_group("animals_group", "update_energy")

func _on_CalcTotalEnergyTimer_timeout():
	total_system_energy = free_energy
	animal_list =  get_tree().get_nodes_in_group("animals_group")
	plant_list =  get_tree().get_nodes_in_group("plants_group")		
	for plant in plant_list:
		total_system_energy += plant.energy
	for animal in animal_list:
		total_system_energy += animal.energy
	print("Animals: ",animal_list.size(), ", Plants: ", plant_list.size(),", free: ", free_energy, ", total: ",total_system_energy)
	print("FPS: ",Performance.get_monitor(Performance.TIME_FPS))

func _on_GetKDTreeForPlantsTimer_timeout():
	plant_list =  get_tree().get_nodes_in_group("plants_group")		
	kt = kdtree.instance()
	add_child(kt)
	# Do KDTree related work
	var pid = 0
	for plant in plant_list:
		kt.insert(plant.position, pid)
		pid += 1
#	kt.show()
		
func _on_calcClosestPlant_timeout():
	animal_list =  get_tree().get_nodes_in_group("animals_group")
	if len(plant_list) == 0 or (not is_instance_valid(kt)) or kt==null:
		for animal in animal_list:
			animal.closest_plant_pos = Vector2.ZERO
			animal.closest_plant_dist = pow(10,9)
		return 
	for animal in animal_list:
		var data = kt.findClosest(animal.position)
		var closestPlant = null
		for key in data["closestQ"].keys():
			closestPlant = key
		if data["closestQ"][closestPlant] > animal.vision_radius:
			animal.within_vision["plant"] = false
		else:
			animal.within_vision["plant"] = true
		animal.closest_plant_pos = Vector2(closestPlant.x, closestPlant.y)
		animal.closest_plant_dist = data["closestQ"][closestPlant]
	kt.deleteTree()
		
func _on_CalcClosestAnimal_timeout():
	animal_list =  get_tree().get_nodes_in_group("animals_group")
	plant_list =  get_tree().get_nodes_in_group("plants_group")		
	ktAnimal = kdtree.instance()
	add_child(ktAnimal)
	# Do KDTree related work
	for animal in animal_list:
		if not animal.activated:
			continue
		ktAnimal.insert(animal.position, animal.unique_id, animal.genes)
	for animal in animal_list:
		if not animal.activated:
			continue
		var data = ktAnimal.findClosest(animal.position, true, 2)
		var closestAnimalPos = Vector2.ZERO
		var distAnimal:float = -1
		var closestAnimalDamage:int = -1
		# finding further of the 2 points since one point is the query animal itself, and further point will be actual closest animal
		for key in data["closestQ"].keys():
			if (Vector2(key.x, key.y) - animal.position).length() > distAnimal:
				distAnimal = (Vector2(key.x, key.y) - animal.position).length() 
				closestAnimalPos = Vector2(key.x, key.y)
				closestAnimalDamage = key.data_dict["damage_capability"]
				
		if distAnimal > animal.vision_radius:
			animal.within_vision["animal"] = false
		else:
			animal.within_vision["animal"] = true
		animal.closest_animal_pos = closestAnimalPos
		animal.closest_animal_dist = distAnimal
		animal.closestAnimalDamageCapability = closestAnimalDamage
	ktAnimal.deleteTree()
func _on_calcClosestPlantOffestTimer_timeout():
	$calcClosestPlant.start()
				
func spawn_initial_animal_batch():
	while num_of_initial_animals_spawned < GlobalVariables.initial_animal_spawn_number:
		spawn_animal(true)
		num_of_initial_animals_spawned += 1

func _on_GameClockTimer_timeout():
	gameTime += 1
