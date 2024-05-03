extends Camera3D

var acceleration = 25
var speed = 5
var mouseSpeed = 300

var velocity = Vector3.ZERO
var lookAngles = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	
	if event is InputEventMouseMotion:
		lookAngles -= event.relative / mouseSpeed

func _process(delta):
	lookAngles.y = clamp(lookAngles.y, PI / -2, PI / 2)
	set_rotation(Vector3(lookAngles.y,lookAngles.x,0))

func _physics_process(delta):
	var dir = Vector3()
	if Input.is_action_pressed("forward"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("back"):
		dir += Vector3.BACK
	if Input.is_action_pressed("left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("right"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("up"):
		dir += Vector3.UP
	if Input.is_action_pressed("down"):
		dir += Vector3.DOWN
	if dir == Vector3.ZERO:
		velocity = Vector3.ZERO
	dir = dir.normalized()
	if dir.length_squared() > 0:
		velocity += dir * acceleration * delta
	if dir.length() > speed:
		velocity = velocity.normalized() * speed
	translate(velocity * delta)
	
	
