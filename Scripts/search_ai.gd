extends "res://Scripts/AI.gd"


@onready var stuckTimer = $Stuck
@onready var brains = $Brains
@onready var indicator : Array = $CanvasLayer/HUD/TextureRect.get_children()


var health = "00001010"

var strength = "10101010"
var hunger
var max_hunger = "10101010"
var food_drain_rate = 1

#Identifies different creature species
var creature_type = 0
#Identifies creature sex
var sex = ""

var foundFood = false
var isReproducing = false
var isWaiting = false
#Used to determine a direction to move in, as well as how many times it should move in that direction
var distanceRemaining = 8
var cardinalDirection = -1

#Essential procceses before running
func _ready():
	distanceToTravel(0)
	wanderMode()
	hunger = binary_to_denary(max_hunger)
 
#process ran every frame
func _physics_process(delta):
	if isWaiting != true:
		#starts a timer if it collides with a wall, continued in function _on_stuck_timeout
		
		if (is_on_wall()) and (stuckTimer.is_stopped() == true):
			stuckTimer.start()
		
		
		#navigation logic
		var direction = Vector3()
		
		#gets the next location it needs to go to
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		#sets velocity of self
		velocity = velocity.lerp(direction * binary_to_denary(speed) , ACCEL * delta)
		
		#adds gravity if not on the floor
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		move_and_slide()

#allows the creature to jump
func jump(direction):
	velocity.y = JUMP_VELOCITY * speed
	lastKnownDirection = direction


	

	move_and_slide()

#ai will wander around the map, ai needs to pick a location within x distance of the nav mesh, and wander to it, if there isnt anything near by that takes priority
func wanderMode():
	#if it will navigate in a new direction
	if foundFood == true:
		foundFood = false
		distanceToTravel(cardinalDirection)
	
		
	
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
	#print(cardinalDirection)
	
	#DEBUG
	#print("direction is")
	#print(dir[cardinalDirection])





#if the timer stops and object is still stuck on wall, it will choose a new path to navigate to
func _on_stuck_timeout():
	if	is_on_wall():
		distanceToTravel(cardinalDirection)
		wanderMode()


func _on_brains_navigation_finished():
	
	#print("target reached")
	
		
	wanderMode()

#if ai spots something of priority, e.g. food, it will move towards it, then attempt to eat it
#if food is collided with, sets it as a target to navigate to, and prevents other food signals overwriting it in future
func _on_food_finder_area_entered(area):
	if isReproducing == false:
		if foundFood == false:
		
			var foodLocation = area.position
			foundFood = true
			nav.target_position = foodLocation

func testCollision():
	print("test")
	print($FoodFinder.get_overlapping_areas())
	

var stored_binary : Array = [128,64,32,16,8,4,2,1]

#converts genetics to a usable value
#PROCCESS - FOR EACH NON 0, TAKE ITS CORROSPONDING BINARY POSITION AND ADDS IT TO TOTAL
#BINARY PASSED MUST BE 8 BIT / 1 BYTE
func binary_to_denary(binary : String):
	var total = 0
	var binary_split = binary.split()
	for i in range(0, binary_split.size()):
		if binary_split[i] != '0':
			total = total + stored_binary[i]
	return total
#used to identify suitable partners
func get_creature_id():
	return self.creature_type
#used to identify whether creatures can reproduce
func get_creature_food_percentage():
	print(self.hunger)
	print (self.binary_to_denary(max_hunger))
	return (self.hunger / self.binary_to_denary(max_hunger))
#used to set hunger after actions
func set_hunger(target_hunger):
	self.hunger = target_hunger
#if two creatures of the same type spot eachother, there is a chance they reproduce


#if ai spots another creature, it will either run away (prey behaviour) or attack it (hunter behaviour)


func _on_animal_behaviour_body_entered(body):
	print("animal search area entered")
	print(body.name)
	if body.name.contains("SearchAI"):
		if body.get_creature_id() == self.get_creature_id():
			print(body.get_creature_food_percentage())
			if ((body.get_creature_food_percentage() >= 0.9) and (self.get_creature_food_percentage() >= 0.9)):
				self.set_hunger(self.hunger / 2)
				body.set_hunger(body.hunger / 2)
				foundFood = false
				
				if sex == "male":
					position = body.position + Vector3(1,0,0)
				if sex == "female":
					self.get_parent().create_creature(self,body)
				get_tree().create_timer(2).timeout
				distanceToTravel(cardinalDirection)
					
					
					
	
func make_child():
	pass





			
		#if (body.isReproducing == true):
			#if self.sex == "female":
				#print("getting parent")
				#self.get_parent().create_creature(self,body)
				#self.isWaiting = false
			#isReproducing = false
			#wanderMode()

