extends Node2D

func _ready():
	pass


func _draw():
	var innerBorderClr:Color = Color(0.3, 1.0, 0.3)
	draw_line(Vector2.ZERO, Vector2(GlobalVariables.map_width,0) , innerBorderClr, 1)
	draw_line(Vector2.ZERO, Vector2(0,GlobalVariables.map_height) , innerBorderClr, 1)
	draw_line(Vector2(GlobalVariables.map_width,GlobalVariables.map_height), Vector2(GlobalVariables.map_width,0) , innerBorderClr, 1)
	draw_line(Vector2(GlobalVariables.map_width,GlobalVariables.map_height), Vector2(0,GlobalVariables.map_height) , innerBorderClr, 1)
	
	var outerBorderClr:Color = Color(1.0, 0.3, 0.3)
	draw_line(Vector2(-GlobalVariables.border_width, -GlobalVariables.border_width), Vector2(GlobalVariables.map_width+GlobalVariables.border_width,-GlobalVariables.border_width) , outerBorderClr, 1)
	draw_line(Vector2(-GlobalVariables.border_width,-GlobalVariables.border_width), Vector2(-GlobalVariables.border_width,GlobalVariables.map_height+GlobalVariables.border_width) , outerBorderClr, 1)
	draw_line(Vector2(GlobalVariables.map_width+GlobalVariables.border_width,GlobalVariables.map_height+GlobalVariables.border_width), Vector2(GlobalVariables.map_width+GlobalVariables.border_width,-GlobalVariables.border_width) , outerBorderClr, 1)
	draw_line(Vector2(GlobalVariables.map_width+GlobalVariables.border_width,GlobalVariables.map_height+GlobalVariables.border_width), Vector2(-GlobalVariables.border_width,GlobalVariables.map_height+GlobalVariables.border_width) , outerBorderClr, 1)
