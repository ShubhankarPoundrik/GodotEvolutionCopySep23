extends Camera2D

var zoom_count = 0
var zoom_speed = 0.9

func _ready():
	position.x = GlobalVariables.map_width/2
	position.y = GlobalVariables.map_height/2

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_Z:
			if zoom_count < 10:
				zoom_count += 1
			zoom = Vector2(1,1)* pow(zoom_speed, zoom_count)
		if event.pressed and event.scancode == KEY_X:
			if zoom_count > -60:
				zoom_count -= 1
			zoom = Vector2(1,1)*pow(zoom_speed, zoom_count)
		var move_amt:int = int(100  * pow(zoom_speed, zoom_count))
		if event.pressed and event.scancode == KEY_DOWN:
			position.y += move_amt
		if event.pressed and event.scancode == KEY_UP:
			position.y -= move_amt
		if event.pressed and event.scancode == KEY_RIGHT:
			position.x += move_amt
		if event.pressed and event.scancode == KEY_LEFT:
			position.x -= move_amt
			
