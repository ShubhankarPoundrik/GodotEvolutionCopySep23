extends RigidBody2D

var energy:int = GlobalVariables.orig_plant_energy
var size:int = 3
#func _ready():
#	randomize()
#	var offset = Vector2(rand_range(-1,1), rand_range(-1,1))
#	offset = offset.normalized() * rand_range(50, min(GlobalVariables.map_height, GlobalVariables.map_width)*0.45)
#	position.x = GlobalVariables.map_width/2 + offset.x
#	position.y = GlobalVariables.map_height/2 + offset.y

func initialize(pos:Vector2):
	position = pos
	set_mass(10 * pow(size, 3))

func setEnergy(val: int):
	energy = val
	


func check_and_delete():
	if energy <= GlobalVariables.orig_plant_energy/10:
		get_parent().free_energy += energy
		energy = 0
		if GlobalVariables.plant_spawn_type == GlobalVariables.Plant_spawn.NEAR_DELETED:
			get_parent().get_node("Queue").push(position) # push_back is same as append
		queue_free()


func _on_checkForOutOfMap_timeout():
	if position.x < 0 or position.x > GlobalVariables.map_width or position.y < 0 or position.y > GlobalVariables.map_height:
		get_parent().free_energy += energy
		energy = 0
		queue_free()
