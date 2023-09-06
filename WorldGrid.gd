extends Node

var width:int = 100
var height:int = 100
var matrix = []
func _ready():
	for x in range(width):
		matrix.append([])
		matrix[x]=[]        
		for y in range(height):
			matrix[x].append([])
			matrix[x][y]={}
			
func updateGrid(animals: Array, plants: Array):
	for a in animals:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
