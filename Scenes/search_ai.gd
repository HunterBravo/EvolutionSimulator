extends "res://Scripts/AI.gd"

@onready var rays : Array = $Rays.get_children()
@onready var stuckTimer = $Stuck
@onready var brains = $Brains
@onready var indicator : Array = $CanvasLayer/HUD/TextureRect.get_children()


var hasTarget = false

#Used to determine a direction to move in, as well as how many times it should move in that direction
var distanceRemaining = 8
var cardinalDirection = -1

#Essential procceses before running
func _ready():
	distanceToTravel(0)
	wanderMode()
#process ran every frame
func _physics_process(delta):
	
	
	
	#starts a timer if it collides with a wall, continued in function _on_stuck_timeout
	
	if (is_on_wall()) and (stuckTimer.is_stopped() == true):
		stuckTimer.start()
	
	
	#navigation logic
	var direction = Vector3()
	
	#gets the next location it needs to go to
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	#sets velocity of self
	velocity = velocity.lerp(direction * SPEED , ACCEL * delta)
	
	#adds gravity if not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

#allows the creature to jump
func jump(direction):
	velocity.y = JUMP_VELOCITY * SPEED
	lastKnownDirection = direction


	

	move_and_slide()

#ai will wander around the map, ai needs to pick a location within x distance of the nav mesh, and wander to it, if there isnt anything near by that takes priority
func wanderMode():
	#if an entity has moved a defined amount of times, it will choose a new direction to go in
	if distanceRemaining == 0:
		distanceToTravel(cardinalDirection)
	 
	
	#OLD CODE TO FALL BACK ON
	#var target = Vector3(position.x + randf_range(-3,3),0,position.z + randf_range(-3,3))
	
	#variables used to determine how many meters an object can move
	var a = -3
	var b = 3
	var c = -3
	var d = 3
	#makes it so you can only travel in a certain direction based on what cardinal you are traveling
	
	#DEBUG
	#print("position is")
	#print(position)
	
	#depending on the cardinal direction, will cause moving in the opposite of that direction impossible
	
	#WEST
	if cardinalDirection == 0:
		a = 1
		
	#NORTH
	elif cardinalDirection == 1:
		c = 1
		
	#EAST
	elif cardinalDirection == 2:
		b = -1
		
	#SOUTH
	elif cardinalDirection == 3:
		d = -1
		
		#sets a target for the navigator to move in
		
						 #A = WEST B = EAST                         C = SOUTH D = NORTH
	var target = Vector3(position.x + randi_range(a,b)   ,1.6,   position.z + randi_range(c,d))
	nav.target_position = target
	
	#DEBUG
	#print("target is")
	#print(target)
	
	#after each movement will minus one from the distance remaining
	distanceRemaining -= 1
	

#chooses the direction of travel, called when you hit a wall or you travel a set distance
func distanceToTravel(direction):
	distanceRemaining = randi_range(8,12)
	var dir : Array = ['W','N','E','S']
	#[1,2,3,4]
	
	#makes sure a duplicate direction is not chosen, 0 called when initialising, otherwise cardinalDirection is passed
	var temp = randi_range(0,3)
	
	while temp == direction:
		temp = randi_range(0,3)
	
	#Sets a directional indicator
	
	indicator[temp].visible = true
	if cardinalDirection != -1:
		indicator[cardinalDirection].visible = false
	
	cardinalDirection = temp
	print(cardinalDirection)
	
	#DEBUG
	print("direction is")
	print(dir[cardinalDirection])


#if ai spots something of priority, e.g. food, it will move towards it, then attempt to eat it

#if ai spots another creature, it will either run away (prey behaviour) or attack it (hunter behaviour)

#if the timer stops and object is still stuck on wall, it will choose a new path to navigate to
func _on_stuck_timeout():
	if	is_on_wall():
		distanceToTravel(cardinalDirection)
		wanderMode()


func _on_brains_navigation_finished():
	
	#print("target reached")
	
	wanderMode()
