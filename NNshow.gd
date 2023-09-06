extends Node2D

export (PackedScene) var nodes

var input_num:int
var output_num:int
var wts:Dictionary
var all_nodes:Array
var connected_nodes: Dictionary
var activations:Dictionary
var node_list: Array
var node_map: Dictionary
var ct = 0
var width = 500
var height = 500
export var attraction_multiplier:float = 0.5
export var repulsion_multiplier:float = 2.5
export var border_multiplier:float = 2.5
export var desired_len = 100
var move_from:int = 0
var stop = false
export var timeout:int = 1000

#func _ready():
#	var wt_dict = {[0,10]:-0.8,[7,5]:0.4,[10,5]:0.66,[10,7]:-0.45,[2,7]:0.01,[7,3]:0.12,[5,4]:0,[1,7]:-1,[2,5]:0.9,[5,3]:-0.5,[13,4]:0.8,[15,14]:0.43,[14,4]:-0.2,[14,17]:0.8}
#	var conn_nds = {}
#	for conn in wt_dict.keys():
#		if not (conn[0] in conn_nds):
#			conn_nds[conn[0]] = []
#		conn_nds[conn[0]].append(conn[1])
#
#		if not (conn[1] in conn_nds):
#			conn_nds[conn[1]] = []
#		conn_nds[conn[1]].append(conn[0])
#	initialize(3, 2, wt_dict, [0,1,2,3,4,5,7,10, 12,13, 14, 15,16,17,18,19], conn_nds)

#	var wt_dict = {[0,10]:0, [10, 3]:0}
#	var conn_nds = {0:[10],10:[0,3],3:[10]}
#	initialize(3, 2, wt_dict, [0,1,2,3,4,5,7,10], conn_nds)
	
func initialize(inNum:int, outNum:int, givenWts:Dictionary, allNds:Array, connNds:Dictionary, activ:Dictionary):
	randomize()
	input_num = inNum
	output_num = outNum
	move_from = input_num+output_num
	connected_nodes = connNds
	activations = activ
	wts = givenWts
	all_nodes = allNds
	var in_dist = height/(input_num+1)
	var out_dist = height/(output_num+1)
	for i in range(input_num):
		var node = nodes.instance()
		add_child(node)
		node.initialize(all_nodes[i], Vector2(100, 10 + (i+1)*in_dist))
	for i in range(input_num, input_num+output_num):
		var node = nodes.instance()
		add_child(node)
		node.initialize(all_nodes[i], Vector2(width-50, 10 + (i-input_num+1)*out_dist), activations[i])
	var num_not_conn = 0
	for i in range(input_num+output_num, len(all_nodes)):
		var node = nodes.instance()
		add_child(node)
		var nodeLbl = all_nodes[i]
		if not (nodeLbl in connected_nodes.keys() ) or (nodeLbl in connected_nodes.keys() and connected_nodes[nodeLbl].size() == 0):
			node.initialize(all_nodes[i], Vector2(50,50+num_not_conn*50), activations[nodeLbl])
			num_not_conn+=1
			continue
		node.initialize(all_nodes[i], Vector2(rand_range(150, width-100),rand_range(100, height-100)), activations[nodeLbl])
		
	node_list = get_tree().get_nodes_in_group("node_group")
	for node in node_list:
		node_map[node.label] = node
	
		
func _process(delta):
	force_direct()
	update()
	
func force_direct():
	var divideBy = 100
	if ct > timeout or stop:
		for i in range(move_from, len(all_nodes)):
			var nodeLbl = all_nodes[i]
			var node = node_map[nodeLbl]
			node.velocity = Vector2.ZERO
			node.accn = Vector2.ZERO
		return
	ct += 1
	var dLen = desired_len/divideBy
	if ct == timeout:
		print("Time out!")
	var max_force = 0
	for i in range(move_from, len(all_nodes)):
		var nodeLbl = all_nodes[i]
		var node = node_map[nodeLbl]
		if not (nodeLbl in connected_nodes.keys() ) or (nodeLbl in connected_nodes.keys() and connected_nodes[nodeLbl].size() == 0):
			node.velocity = Vector2.ZERO
			node.accn = Vector2.ZERO
			continue
		var nodePos = node.position/divideBy
		var finalForce:Vector2 = Vector2.ZERO
		# Attraction
		if nodeLbl in connected_nodes.keys():
			for nb in connected_nodes[nodeLbl]:
				var neighbour = node_map[nb]
				var nbPos = neighbour.position/divideBy
#				print(str(nbPos)+" "+str(nodePos)+" "+str(desired_len)+" "+str(divideBy))
				finalForce += attraction_multiplier*(nbPos-nodePos).normalized()*log((nbPos-nodePos).length()/dLen)
				
#		print("finalF 1: "+str(finalForce))
		# Repulsion
		for nb in all_nodes:
			if nb == nodeLbl:
				continue
			var neighbour = node_map[nb]
			var nbPos = neighbour.position/divideBy
			finalForce -= repulsion_multiplier*(nbPos-nodePos).normalized()/(nbPos-nodePos).length_squared()
			
#		print("finalF 2: "+str(finalForce))
		var border_list = [Vector2(1, nodePos.y),Vector2((width-50)/divideBy, nodePos.y),Vector2(nodePos.x, 0),Vector2(nodePos.x, height/divideBy)]
		for nbPos in border_list:
			finalForce -= border_multiplier*(nbPos-nodePos).normalized()/(nbPos-nodePos).length_squared()
		node.accn =  finalForce
		max_force = max(finalForce.length(), max_force)
#	print(max_force)
	if max_force < 1:
		stop = true
		print("ct: "+str(ct))
		
func _draw():
	draw_rect(Rect2(0,0,width,height), Color(0.05,0.05,0.05))
	for wt in wts:
		var frmNd = wt[0]
		var toNd = wt[1] 
#		(1 + (int(wts[wt]<0)*2-1)*wts[wt])/2
		var clr = Color(max(0,-wts[wt]), max(0, wts[wt]), 0 )
		draw_line(node_map[frmNd].position, node_map[toNd].position, Color(0.5,0.5,0.5), 8)
		draw_line(node_map[frmNd].position, node_map[toNd].position, clr, 6)
		draw_line(node_map[frmNd].position+0.6*(node_map[toNd].position-node_map[frmNd].position), node_map[toNd].position, clr, 15)
		
	draw_line(Vector2(0,0), Vector2(width, 0), Color(0.1,0.1,0.1), 6)
	draw_line(Vector2(0,0), Vector2(0, height), Color(0.1,0.1,0.1), 6)
	draw_line(Vector2(0,height), Vector2(width,height), Color(0.1,0.1,0.1), 6)
	draw_line(Vector2(width,0), Vector2(width,height), Color(0.1,0.1,0.1), 6)
	
				
		
				
		
	
	
	
		

	
