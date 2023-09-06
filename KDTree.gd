extends Node

var x 
var y 
var id = -1
var data_dict:Dictionary = {}
var left_bottom_child
var right_top_child
var loadedKDTree :=load("res://KDTree.tscn")

func show(tabs=0):
	var tabs_str = ""
	for _i in range(tabs):
		tabs_str = tabs_str + "    "
	print(tabs_str,"x:",x," y:",y," id:",id)
	if left_bottom_child:
		print(tabs_str,"lbc:")
		left_bottom_child.show(tabs+1)
	if right_top_child:
		print(tabs_str,"rtc:")
		right_top_child.show(tabs+1)

func insert(point: Vector2, pid, dd={}, divx = true):
	if x == null:
		x = point.x
		y = point.y
		id = pid
		data_dict = dd
		return
	if (divx and x > point.x) or (not divx and y > point.y):
		if left_bottom_child == null:
			left_bottom_child = loadedKDTree.instance()
			left_bottom_child.x = point.x
			left_bottom_child.y = point.y
			left_bottom_child.id = pid
			left_bottom_child.data_dict = dd
		else:
			left_bottom_child.insert(point, pid, dd, not divx)
	else:
		if right_top_child == null:
			right_top_child = loadedKDTree.instance()
			right_top_child.x = point.x
			right_top_child.y = point.y
			right_top_child.id = pid
			right_top_child.data_dict = dd
		else:
			right_top_child.insert(point, pid, dd, not divx)
			
func dist(p1:Vector2,p2:Vector2):
	return (p1-p2).length()
				
func findClosest(point: Vector2, divx=true, k:int=1):
	var closestQ:Dictionary = {}
	var maxDistInK:float = -1
	
	if self.x == null or self.y == null:
		return {"closestQ":closestQ}
	var selfDist = dist(Vector2(self.x, self.y), Vector2(point.x, point.y) )
	closestQ[self] = selfDist
	if left_bottom_child == null and right_top_child == null:	
		return {"closestQ":closestQ}
	if (divx and x > point.x) or (not divx and y > point.y):
		if left_bottom_child != null:
			var result = left_bottom_child.findClosest(point, not divx, k)	
			for k in result["closestQ"].keys():
				closestQ[k] = result["closestQ"][k]
			while len(closestQ) > k:
				var maxD:float = -1
				var maxDNode = null
				for key in closestQ.keys():
					if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
						maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
						maxDNode = key
				closestQ.erase(maxDNode)
			for k in closestQ.keys():
				if closestQ[k] > maxDistInK:
					maxDistInK = closestQ[k]

		if divx and x > point.x:
			# went left
			if abs(point.x - x) < maxDistInK and right_top_child != null:
				var result = right_top_child.findClosest(point, not divx, k)
				for k in result["closestQ"].keys():
					closestQ[k] = result["closestQ"][k]
				while len(closestQ) > k:
					var maxD:float = -1
					var maxDNode = null
					for key in closestQ.keys():
						if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
							maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
							maxDNode = key
					closestQ.erase(maxDNode)
		else:
			# went bottom
			if abs(point.y - y) < maxDistInK and right_top_child != null:
				var result = right_top_child.findClosest(point, not divx, k)
				for k in result["closestQ"].keys():
					closestQ[k] = result["closestQ"][k]
				while len(closestQ) > k:
					var maxD:float = -1
					var maxDNode = null
					for key in closestQ.keys():
						if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
							maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
							maxDNode = key
					closestQ.erase(maxDNode)
	else:
		if right_top_child != null:
			var result = right_top_child.findClosest(point, not divx, k)
			for k in result["closestQ"].keys():
				closestQ[k] = result["closestQ"][k]
			while len(closestQ) > k:
				var maxD:float = -1
				var maxDNode = null
				for key in closestQ.keys():
					if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
						maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
						maxDNode = key
				closestQ.erase(maxDNode)
			for k in closestQ.keys():
				if closestQ[k] > maxDistInK:
					maxDistInK = closestQ[k]
		if divx and x < point.x:
			# went right
			if abs(point.x - x) < maxDistInK and left_bottom_child != null:
				var result = left_bottom_child.findClosest(point, not divx, k)
				for k in result["closestQ"].keys():
					closestQ[k] = result["closestQ"][k]
				while len(closestQ) > k:
					var maxD:float = -1
					var maxDNode = null
					for key in closestQ.keys():
						if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
							maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
							maxDNode = key
					closestQ.erase(maxDNode)
		else:
			# went top
			if abs(point.y - y) < maxDistInK and left_bottom_child != null:
				var result = left_bottom_child.findClosest(point, not divx, k)
				for k in result["closestQ"].keys():
					closestQ[k] = result["closestQ"][k]
				while len(closestQ) > k:
					var maxD:float = -1
					var maxDNode = null
					for key in closestQ.keys():
						if dist(Vector2(key.x, key.y), Vector2(point.x, point.y)) > maxD:
							maxD=dist(Vector2(key.x, key.y), Vector2(point.x, point.y))
							maxDNode = key
					closestQ.erase(maxDNode)
	return {"closestQ":closestQ}

func deleteTree():
	if right_top_child != null:
		right_top_child.deleteTree()
	if left_bottom_child!=null:
		left_bottom_child.deleteTree()
	queue_free()

