extends Node

var input_num:int = GlobalVariables.input_num
var output_num:int = GlobalVariables.output_num
var visible_num:int = input_num + output_num
var outL = {}
var inL = {}
var all_nodes:Array =  []
var non_output_nodes:Array = []
var values = {}
var min_dist = {}
var max_node:int = input_num + output_num - 1
var wts = {}
var INFINITY:int = pow(10, 9)
enum Activation {TANH=0, INVTANH=1}
var activations:Dictionary={} # input nodes all have tanh. This is for rest (non-input nodes).

func ri(min_val, max_val):
	randomize()
	return min_val + randi()%(max_val - min_val + 1)
	
func sigmoid(val: float):
	return 1/(1 + exp(-val))

func inverseTanh(val:float):
	if val == 0:
		return 0
	else:
		return tanh(1.0/val)
	
func _ready():
	randomize()
	for i in range(visible_num):
		all_nodes.append(i)
	for i in range(input_num):
		non_output_nodes.append(i)
	for i in all_nodes:
		values[i] = -INFINITY
		min_dist[i] = -INFINITY
	for i in range(input_num, visible_num):
		activations[i] = Activation.keys()[ri(0, len(Activation)-1)]
	
func recurseEval(node: int):
	if values[node] != -INFINITY:
		return values[node]
	var value = 0
	for pre in inL.get(node, []):
		value += recurseEval(pre) * wts[[pre, node]]
	if Activation[activations[node]] == Activation.TANH:
		value = tanh(value)
	elif Activation[activations[node]] == Activation.INVTANH:
		value = inverseTanh(value)
	values[node] = value
	return value


func evaluate(input_vals: Array):
#	print("Input: ", input_vals)
	for i in range(input_num):
		values[i] = input_vals[i]
	var out_vals = []
	for _i in range(output_num):
		out_vals.append(0)
	for onode in range(input_num, visible_num):
		out_vals[onode - input_num] = recurseEval(onode)
	for i in values.keys():
		values[i] = -INFINITY
#	print("Output: ", out_vals)
	return out_vals
	
func cyclePresent():
	var inDegs = {}
	for i in all_nodes:
		inDegs[i] = inL.get(i, []).size()
	var q = []
	var ct = 0
	for i in inDegs.keys():
		if inDegs[i] == 0:
			q.append(i)
	while q.size() > 0:
		var el = q.pop_front()
		ct += 1
		for nb in outL.get(el, []):
			inDegs[nb] -= 1
			if inDegs[nb] == 0:
				q.append(nb)
	return ct != all_nodes.size()
	
func mutate(delNode, delConn, addNode, addConn, modifyConn, modifyTimes,completelyNewChance,activationChange):
	randomize()
	# print("========== Mutate =========")
	var result = {"success":false}
	if modifyTimes == -1:
		modifyTimes = len(wts) 
	if rand_range(0,1) < delNode:
		result = delNode()
#		print("delNode ", result)
	if rand_range(0, 1) < addNode:
		result = addNode()
#		print("addNode ", result)
	if rand_range(0, 1) < addConn:
		result = addConn()
#		print("addConn ", result)
	if rand_range(0, 1) < delConn:
		result = delConn()
#		print("delConn ", result)
	if rand_range(0, 1) < activationChange:
		result = modifyActivation()
	else:
		pass
	for _i in range(modifyTimes):
		if rand_range(0, 1) < modifyConn:
			result = modifyConn(completelyNewChance)
#		print("modifyConn ", result)		
		
func addNode():
	randomize()
	if wts.keys().size() == 0:
		return
	var src_dest = wts.keys()[randi() % wts.keys().size()]
	var src = src_dest[0]
	var dest = src_dest[1]
	var newNode = max_node + 1
	max_node += 1

	inL[dest].append(newNode)
	inL[dest].erase(src)

	outL[src].append(newNode)
	outL[src].erase(dest)

	inL[newNode] = [src]
	outL[newNode] = [dest]
	values[newNode] = -INFINITY
#	print("Adding ", newNode, " b/w ", src , " & ", dest)
	wts[[src, newNode]] = wts[[src, dest]]
	wts[[newNode, dest]] = 1
#	print(wts[[src, newNode]], " & ", wts[[newNode, dest]])
	wts.erase([src, dest])
#	print("Erased old conn  b/w ", src , " & ", dest, " = ", wts)
	non_output_nodes.append(newNode)
	all_nodes.append(newNode)
	activations[newNode] = Activation.keys()[ri(0, len(Activation)-1)]
	min_dist[newNode] = INFINITY
	return {"success":true, "src":src, "dest":dest, "newNode":newNode}

func addConn():
	randomize()
	var ct = 0
	while ct < len(all_nodes):
		ct += 1
		# add a connection
		# select 2 random nodes with dest node being non input node
		var src = -1
		var dest = -1
		var goodConn = false
		var ct2 = 0
		while not goodConn:
			ct2 += 1
			if ct2 == 5:
				return {"success":false, "src":-1,"dest":-1,"wt":-1}
			src = non_output_nodes[ri(0, len(non_output_nodes)-1)]
			# first in_num in all_nodes are input nodes
			dest = all_nodes[ri(input_num, len(all_nodes)-1)]
			if [src, dest] in wts or [dest, src] in wts:
				continue
			goodConn = true
		if dest in inL:
			inL[dest].append(src)
		else:
			inL[dest] = [src]
		if src in outL:
			outL[src].append(dest)
		else:
			outL[src] = [dest]
		wts[[src, dest]] = rand_range(-1, 1)
		if not cyclePresent():
			# SUCCESS
			return {"success":true, "src":src,"dest":dest,"wt":wts[[src, dest]]}
		inL[dest].pop_back()
		outL[src].pop_back()
		wts.erase([src, dest])
	return {"success":false, "src":-1,"dest":-1,"wt":-1}

func addThisConn(src, dest, conn_wt):
	if [src, dest] in wts:
		return {"success":false, "src":-1,"dest":-1,"wt":-1}
	if dest in inL:
		inL[dest].append(src)
	else:
		inL[dest] = [src]
	if src in outL:
		outL[src].append(dest)
	else:
		outL[src] = [dest]
	wts[[src, dest]] = conn_wt
	if not cyclePresent():
		# SUCCESS
		return {"success":true, "src":src,"dest":dest,"wt":wts[[src, dest]]}
	inL[dest].pop_back()
	outL[src].pop_back()
	wts.erase([src, dest])
	return {"success":false, "src":-1,"dest":-1,"wt":-1}

func delNode():
	randomize()
	if len(all_nodes) - input_num - output_num <= 1:
		return {"success":false, "deleted_node":-1}
	var nd = all_nodes[ri(input_num+output_num, len(all_nodes)-1)]
	non_output_nodes.erase(nd)
	activations.erase(nd)
	all_nodes.erase(nd)
	values.erase(nd)
	min_dist.erase(nd)
	if nd == max_node:
		max_node = all_nodes.max()
	var toDel = []
	for key in wts.keys():
		if key[0] == nd:
			toDel.append(key)
			inL[key[1]].erase(nd)
		if key[1] == nd:
			toDel.append(key)
			outL[key[0]].erase(nd)
	for key in toDel:
		wts.erase(key)
	inL.erase(nd)
	outL.erase(nd)
	return {"success":true, "deleted_node":nd}

func delConn():
	randomize()
	if len(wts) == 0:
		return {"success":false, "src":-1, "dest":-1}
	var src_dest = wts.keys()[randi() % wts.keys().size()]
	var src = src_dest[0]
	var dest = src_dest[1]
	inL[dest].erase(src)
	outL[src].erase(dest)
	wts.erase([src, dest])
	return {"success":true, "src":src, "dest":dest}


func modifyConn(completelyNewChance):
	randomize()
	if len(wts) == 0:
		return {"success":false, "src":-1, "dest":-1}
	var src_dest = wts.keys()[randi() % wts.keys().size()]
	var src = src_dest[0]
	var dest = src_dest[1]
	if rand_range(0, 1) < completelyNewChance:
		wts[[src, dest]] = rand_range(-1, 1)
	else:
		wts[[src, dest]] = clamp(wts[[src, dest]] + rand_range(-0.05, 0.05), -1, 1)
		# all wts b/w [-1, 1]
	return {"success":true, "src":src, "dest":dest}

func modifyActivation():
	randomize()
	var key:int = activations.keys()[ri(0, len(activations)-1)]
	activations[key] = Activation.keys()[ri(0, len(Activation)-1)]
	return {"success":true, "node":key}
			

