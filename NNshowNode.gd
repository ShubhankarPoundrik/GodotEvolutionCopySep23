extends KinematicBody2D

var velocity:Vector2
var accn:Vector2
var label:int
var speed = 0.5
var MAX_ACCN:float = 4.0
var MAX_VELOCITY:float = 200.0

func initialize(lbl:int, posn:Vector2, activation:String="TANH"):
	position = posn
	label = lbl
	$Sprite.get_node("NodeNum").set_text(str(lbl)+"|"+activation)
	
func _physics_process(delta):
	if accn.length() > MAX_ACCN:
		accn = accn.normalized()*MAX_ACCN
	velocity += accn
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.normalized()*MAX_VELOCITY
	var collObj = move_and_collide(velocity*delta*speed)
	if collObj:
		velocity = velocity.bounce(collObj.normal)
