extends RigidBody2D

var force_exerted: Vector2 = Vector2.ZERO
var energy:int = 0
var birth_energy:int = 0
var closest_animal_pos := Vector2.ZERO
var closest_plant_pos := Vector2.ZERO
var closest_plant_dist:float = pow(10, 9)
var closest_animal_dist:float = pow(10, 9)
var props:Dictionary = {}
var energy_used_multiplier:float = 4000
var unique_id:float = -1
var closestAnimalDamageCapability:int = 0
var activated:bool = false
var action:Array = []
var sprite_direction:Vector2 = Vector2.ZERO
#export (Curve) var damage_capability_expression_curve

export var vision_radius:int = 0

var within_vision:Dictionary = {"animal":false, "plant":false}

var genes: Dictionary = {"size":0.3,"speed_factor":0.3,"damage_capability":0.0, "activation_time":0.3, 
"RColor":0.5, "GColor":0.5, "BColor":0.6,"MouthRColor":0.5, "MouthGColor":0.5, "MouthBColor":0.6}

var size:float = 0
var health:int = 0
var speed:float = 0
var damage_capability:int = 0
var activation_time:int = 0

func set_gene_phenotype():
	#var genes: Array = [(1, 5), (1,3), (0,max_damage_capability)]
	size = (genes["size"]*5.0 + 1.0)
	set_mass(pow(size, 3))
	speed = (genes["speed_factor"]*3+1)*GlobalVariables.linear_speed_multiplier
	#damage_capability = int(damage_capability_expression_curve.interpolate(genes["damage_capability"])*GlobalVariables.max_damage_capability)
	activation_time = int((genes["activation_time"]*0.8+0.2) * GlobalVariables.max_activation_time)
	set_activation_time_timer_wait(activation_time)
	set_size(size)
	vision_radius = 700*(2*genes["size"]+1)
	
func set_genes_as_mutated_parent_genes(parent_genes):
	randomize()
	for key in parent_genes.keys():
		genes[key] = clamp( parent_genes[key]+rand_range(-0.05,0.05) , 0, 1)

func tanh(val: float):
	return (exp(val) - exp(-val))/(exp(val) + exp(-val))

func printDetails():
	var strToDisplay:String = ""
	strToDisplay += ("========================================")
	strToDisplay += ("id: "+ str(unique_id))
	strToDisplay += ("All nodes: "+ str($NN.all_nodes))
	strToDisplay += ("Weights: "+str($NN.wts))
	strToDisplay += (", Force: "+str(force_exerted))
	strToDisplay += ("Genes: "+str(genes))
	strToDisplay += ("========================================")
	print(strToDisplay)
	
func getDetailsToDisplay():
	var strToDisplay:String = ""
	strToDisplay += ("id: "+ str(unique_id))
	strToDisplay += ("\nEnergy: "+ str(energy))
	strToDisplay += (", Health: "+ str(health))
	strToDisplay += ("\nNN output: "+ str(action))	
	strToDisplay += (", Force: "+str(force_exerted))
	strToDisplay += (", Facing: "+str(sprite_direction))
	strToDisplay += (", Velocity: "+str(linear_velocity))
	strToDisplay += ("\nGenes: "+ str(genes))
	strToDisplay += ("\nGen: "+ str(props["generation"]))
	strToDisplay += (", activated: "+ str(activated))
	strToDisplay += ("\ninputs: "+ str("0: angle_to_plant,1: dist_to_plant,2: angle_to_animal,3: dist_to_animal, 4:closestAnimalDamageCapability, 5:const"))
	return strToDisplay
	
func _ready():
#	print("====================================================")
#	print("Readying animal...")
	randomize()
	unique_id = randi()%1000000000
	props = {"generation":0}
	$Sprite.modulate = Color(1,1,1)
	$AggrSprite.modulate = Color(1,1,1)
	
	if props["generation"] == 0:
		set_gene_phenotype()

func set_activation_time_timer_wait(val:float):
	$ActivateTimer.start(val)
	
func mutate_first_gen():
#	print("Mutating 1st gen")
	energy = int(GlobalVariables.orig_animal_energy * pow(size, 3))
	birth_energy = energy
	var success:bool = $NN.addThisConn(0, 6, 0.5)["success"]
	assert(success==true)
	#(delNode=0.2, delConn=0.6, addNode=0.2, addConn=0.6, modifyConn=0.9, modifyTimes=-1,completelyNewChance=0.2,activationChange=0.15)
	
	$NN.mutate(0, 0, 0.1, 0.9, 0, 0, 0, 0.1)
	
#	print("first gen: ", $NN.wts)
func set_pos(pos:Vector2):
	position = pos


func _on_ActivateTimer_timeout():
	if not activated:
		activated = true
		$Sprite.modulate = Color(genes["RColor"], genes["GColor"],genes["BColor"])
		$AggrSprite.modulate = Color(genes["MouthRColor"], genes["MouthGColor"],genes["MouthBColor"])
		
func _process(delta):
	if not activated:
		return
	if position.x < -GlobalVariables.border_width or position.x > GlobalVariables.map_width+GlobalVariables.border_width or position.y < -GlobalVariables.border_width or position.y > GlobalVariables.map_height+GlobalVariables.border_width:
		get_parent().free_energy += energy
		energy = 0
		queue_free()
		
	var energy_to_give:int = int(GlobalVariables.orig_animal_energy * pow(size, 3))
	if energy >= 2 * energy_to_give:
		energy -= energy_to_give
		get_parent().spawn_child_animal(position, $NN, genes, props, energy_to_give)		
	update()


func set_size(val:float):
	$Sprite.scale = Vector2(1,1) * val
	$CollisionShape2D.scale = Vector2(1,1) * val
	$AggrSprite.scale = Vector2(1,1) * val
	
func init(parent_position, nn, parent_genes, parent_props, energy_passed, if_mutate=true):
	
	energy = energy_passed
	birth_energy = energy_passed
	randomize()
	var parent_genes_deep_copy = parent_genes.duplicate()
	if if_mutate:
		set_genes_as_mutated_parent_genes(parent_genes_deep_copy)
	else:
		genes = parent_genes_deep_copy
	set_gene_phenotype()
	
	props = parent_props.duplicate()
	props["generation"] = props["generation"] + 1
	
	$Sprite.modulate = Color(1,1,1)
	$AggrSprite.modulate = Color(1,1,1)	
	parent_position.x += rand_range(-GlobalVariables.offset_from_parent,GlobalVariables.offset_from_parent)
	parent_position.y += rand_range(-GlobalVariables.offset_from_parent,GlobalVariables.offset_from_parent)
	position.x = parent_position.x
	position.y = parent_position.y
#	print("Parent nn mutated to overwrite child NN")	
	$NN.input_num = nn.input_num
	$NN.output_num = nn.output_num
	$NN.visible_num = nn.visible_num
	$NN.outL = str2var(var2str(nn.outL)) #deep copy
	$NN.inL = str2var(var2str(nn.inL)) #deep copy
	$NN.all_nodes =  nn.all_nodes.duplicate()
	$NN.non_output_nodes = nn.non_output_nodes.duplicate()
	$NN.values = str2var(var2str(nn.values))
	$NN.min_dist = str2var(var2str(nn.min_dist))
	$NN.max_node = nn.max_node
	$NN.wts = str2var(var2str(nn.wts))
	$NN.activations = str2var(var2str(nn.activations))
	#print("Before: ", $NN.wts, $NN.inL, $NN.outL)
	if if_mutate:
		#(delNode=0.2, delConn=0.6, addNode=0.2, addConn=0.6, modifyConn=0.9, modifyTimes=-1,completelyNewChance=0.2,activationChange=0.15)
		for i in range(len($NN.wts) + 1):
			$NN.mutate(0.05, 0.1, 0.05, 0.1, 0.8, 1, 0.05, 0.05)
	#print("After: ", $NN.wts, $NN.inL, $NN.outL)
		
func update_energy():
	if not activated:
		return
	var energy_used:int = int(energy_used_multiplier*( pow(size, 2.7) * (1 + 0.5*genes["speed_factor"] ) ))
	assert( energy_used > 0)

	var energy_spent = min(energy_used, energy)
	energy -= energy_spent
	get_parent().free_energy += energy_spent
			
	if energy <= 0:
		queue_free()
			
func _physics_process(delta):
	apply_central_impulse(force_exerted)
	
	if delta > 0.018:
		print("\nPhysics processing lag\n")
		
	var colls = $AggrSprite/Area2D.get_overlapping_bodies()
	for body in colls:
		if body.is_in_group("plants_group"):
#			print("Collision with plant: "+str(energy))
			if body.energy > 0:
				var energy_transferred:int = int(GlobalVariables.orig_plant_energy*pow(size, 3)/125/80)
				if energy_transferred > body.energy:
					energy_transferred = body.energy
				energy += energy_transferred
				body.setEnergy(body.energy - energy_transferred)
				body.check_and_delete()
#			print("Updated: "+str(energy))
			
			
		
func set_energy(val: int):
	energy = val
	
func set_health(val: int):
	health = val
	
func change_accn():
	# All inputs within [-1, 1]
#	print("Animal posn: ", position)
	if not activated:
		return
	sprite_direction = Vector2(0, -1).rotated($Sprite.global_rotation_degrees*PI/180.0)
	var vect_to_closest_plant:Vector2 = closest_plant_pos - position
	var vect_to_closest_animal:Vector2 = closest_animal_pos - position
	var angle_to_plant:float = sprite_direction.angle_to(vect_to_closest_plant)
	var angle_to_animal:float = sprite_direction.angle_to(vect_to_closest_animal)
	var dist_to_plant:float = 2*closest_plant_dist/vision_radius # tanh(x) is ~= 1 for all x>2, so x=3 & x=4 will be same to NN, but 1.5,0.7 & 1.8 will be different
	var dist_to_animal:float = 2*closest_animal_dist/vision_radius
	if not within_vision["plant"]:
		angle_to_plant = 0
		dist_to_plant = 10
	if not within_vision["animal"]:
		angle_to_animal = 0
		dist_to_animal = 10 # tanh(10) ~= 1, infact its 0.9999... at 5
	var nn_inpts = [angle_to_plant, dist_to_plant, angle_to_animal, dist_to_animal, closestAnimalDamageCapability, 1]
	for i in range(len(nn_inpts)):
		nn_inpts[i] = tanh(nn_inpts[i])
#	print(nn_inpts)
	action = $NN.evaluate(nn_inpts) # all outputs b/w [-1,1] 
	apply_torque_impulse(GlobalVariables.rotational_speed_multiplier * pow(size, 2) * action[0])
	force_exerted = 5 * pow(size, 2) * speed * sprite_direction * ((1+action[1])/2) # 0.15 ~= PI/20
	
	
	
#func _draw():
#	if not activated:
#		return
#	if within_vision["plant"]:
#		draw_line(Vector2.ZERO, closest_plant_pos - position, Color(0.4,0.4,0.4), 1)
#	if within_vision["animal"]:
#		draw_line(Vector2.ZERO, closest_animal_pos - position, Color(0.1,0.1,0.5), 1)

