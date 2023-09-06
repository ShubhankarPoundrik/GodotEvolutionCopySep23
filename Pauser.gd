extends Node2D

export (PackedScene) var nnShow
export (PackedScene) var plants

var animal_to_circle
var nn_panel_open:bool = false
var drawing_plants:bool = false

func _process(delta):
	if nn_panel_open:
		update()
		
	if (animal_to_circle != null) and (is_instance_valid(animal_to_circle)):
		get_parent().get_node("AnimalDetailsCanvas/SelectedAnimalStatsDisplay").set_text(animal_to_circle.getDetailsToDisplay())
	else:
		get_parent().get_node("AnimalDetailsCanvas/SelectedAnimalStatsDisplay").set_text("")
	
		
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			toggle_pause()
			
		if event.pressed and event.scancode == KEY_D:
			# select the nearest animal and show its brain
			var nn_show_list = get_tree().get_nodes_in_group("NN_display_group")
			if len(nn_show_list) != 0:
				for n in nn_show_list:
					n.queue_free()
				nn_panel_open = false
				animal_to_circle = null
				update()
#				print("Deleted all NN displays")
				return
			nn_panel_open = true
			var animal_list = get_tree().get_nodes_in_group("animals_group")
			var minDistInd = -1
			var minDistSq = pow(GlobalVariables.map_width+GlobalVariables.map_height + 1000,2)
			var mouse_pos = get_global_mouse_position()
			for i in range(len(animal_list)):
				var dist = (animal_list[i].position-mouse_pos).length_squared()
#				print(str(i)+ "   "+str(animal_list[i].position)+"  "+str(mouse_pos)+"  "+ str(dist))
				if dist < minDistSq:
					minDistSq = dist
					minDistInd = i
#			print("Animal lsit: "+ str(animal_list))
#			print("Mouse: "+str(mouse_pos))
#			print("minDistInd: ",minDistInd)
			var animal = animal_list[minDistInd]
			animal_to_circle = animal
			animal.printDetails()
			var nn_node = animal.get_node("NN")
			var animal_nn_wts:Dictionary = nn_node.wts
			var inNum:int = nn_node.input_num
			var outNum:int = nn_node.output_num
			var allNodes:Array = nn_node.all_nodes
			var inL:Dictionary = nn_node.inL
			var outL:Dictionary = nn_node.outL
			var node_conns:Dictionary = {}
			for k in inL.keys():
				if not (k in node_conns.keys()):
					node_conns[k] = []
				var conns = inL[k]
				for nb in conns:
					node_conns[k].append(nb)
			for k in outL.keys():
				if not (k in node_conns.keys()):
					node_conns[k] = []
				var conns = outL[k]
				for nb in conns:
					node_conns[k].append(nb)
			var nns = nnShow.instance()
			get_parent().get_node("NNCanvas").add_child(nns)
			nns.initialize(inNum,outNum,animal_nn_wts,allNodes,node_conns,nn_node.activations)
#			print("Added NNshow to canvas")
		if event.pressed and event.scancode == KEY_C:
			var mouse_pos = get_global_mouse_position()
			if not drawing_plants:
				var plant = plants.instance()
				get_parent().add_child(plant)
				plant.initialize(mouse_pos)
				print("Spawned one plant @ "+ str(mouse_pos))
			else:
				var num_to_spawn:int = get_parent().get_node("CanvasLayer").get_node("PlantSpawnerSpinBox").value
				print("Pauser.gd: Num to spawn: "+str(num_to_spawn))
				var radius_multiplier:float = GlobalVariables.plant_spawn_distance_multiplier
				var radius:float = radius_multiplier*pow(num_to_spawn, 0.5)
				var spawned_num:int = 0
				for _i in range(num_to_spawn):
					var offset = radius*Vector2(rand_range(-1,1), rand_range(-1,1))
					if offset.length() > radius:
						offset = radius * offset.normalized() * rand_range(0.2,0.9)
					var spawn_pos =  mouse_pos+offset
					if spawn_pos.x<30 or spawn_pos.x>GlobalVariables.map_width-30 or spawn_pos.y<30 or spawn_pos.y>GlobalVariables.map_height-30:
						continue
					var plant = plants.instance()
					get_parent().add_child(plant)
					plant.initialize(spawn_pos)
					spawned_num += 1
				print("Pauser.gd: Spawned num: "+str(spawned_num))
		if event.pressed and event.scancode == KEY_ENTER:
			get_parent().get_node("CanvasLayer").get_node("PlantSpawnerSpinBox").get_line_edit().release_focus()
		if event.pressed and event.scancode == KEY_B:
			drawing_plants = not drawing_plants
			if not drawing_plants:
				get_parent().get_node("CanvasLayer").get_node("PlantSpawnerSpinBox").hide()
			else:
				get_parent().get_node("CanvasLayer").get_node("PlantSpawnerSpinBox").show()
			
	
func toggle_pause():
	GlobalVariables.paused = not GlobalVariables.paused
	get_tree().paused = GlobalVariables.paused

func set_pause(toPause=true):
	GlobalVariables.paused = toPause
	get_tree().paused = GlobalVariables.paused
	
func _draw():
	if (animal_to_circle == null) or not(is_instance_valid(animal_to_circle)):
		return
	draw_circle(animal_to_circle.position,animal_to_circle.vision_radius,Color(0,0,0,0.1))
	draw_circle(animal_to_circle.position,250,Color(0,0,0,0.5))
	
