extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var lastKnownDirection = Vector3()

var speed = "00000010"
const ACCEL = 10
const JUMP_VELOCITY = 10

@onready var nav: NavigationAgent3D = $Brains
@onready var Target = $"../Target"

var targeted = false




func _physics_process(delta):
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var direction = Vector3()
	if targeted == false:
		nav.target_position = Target.global_position
		targeted = true

	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	print(direction.x)
	
	if (direction.y > 0.26) and (is_on_floor()):
		jump(direction)
	
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		velocity.x += lastKnownDirection.x * delta
		velocity.z += lastKnownDirection.z * delta
		
		
		
	move_and_slide()

func jump(direction):
	velocity.y = JUMP_VELOCITY * speed
	lastKnownDirection = direction
	
