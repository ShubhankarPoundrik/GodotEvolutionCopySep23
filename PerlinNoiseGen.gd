extends Node2D

var tile_map:Array = []
var noise
var width:int = 100
var height:int = 100
var sum:float = 0
var prefix_sum:Array = []

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
#	initialize(100,100)

func initialize(wd,ht):
	width = wd-1
	height = ht-1
	# Configure
	noise.seed = randi()
	noise.octaves = 1
	noise.period = max(width, height)/2
	noise.persistence = 0.7
	
	for _i in range(width*height):
		tile_map.append(0)
		prefix_sum.append(0)
	
	for x in range(width):
		for y in range(height):
			var ns:float = ( noise.get_noise_2d(float(x), float(y)) +1 )/2
			ns = pow(ns,4)
			tile_map[x*height + y] = ns
			sum += ns
			prefix_sum[x*height + y] = sum
			
#	print(tile_map.slice(0, 20))
#	print("Sum: "+str(sum))
	
func getPerlinPosition():
	var randomNum:float = rand_range(0, sum)
	# binary search on prefix_sum to get index of number closest to randomNum, and return the index. Convert index to 2d (x,y) before returning
	var index:int = prefix_sum.bsearch(randomNum)
	return Vector2(index/height+1, index % height+1) 
	


#func _draw():
#	for x in range(width):
#		for y in range(height):
#			var clr = tile_map[x*height + y]
#			draw_circle(Vector2(x,y), 1, Color(clr,clr,clr))


