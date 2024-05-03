extends CharacterBody3D

#onready scenes
@onready var stuckTimer = $Stuck
@onready var brains = $Brains
@onready var indicator : Array = $CanvasLayer/HUD/TextureRect.get_children()
@onready var nav: NavigationAgent3D = $Brains
@onready var hungerTimer = $HungerTimer
@onready var huntTimer = $HuntTimer
@onready var fightTimer = $FightTimer
@onready var sphere = $Body
var lastKnownDirection = Vector3()
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const ACCEL = 10
const JUMP_VELOCITY = 10

var health = "00001010"
var realHealth
var speed = "00000001"
var realSpeed
var strength = "10101010"
var realStrength
var hunger
var max_hunger = "10101010"
var food_drain_rate = 0
#Identifies different creature species
var creature_type = 0
#Identifies creature sex
var sex = ""

#variables relating to fighting
var isChasing = false
var isFighting = false
var fightTarget

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
	realSpeed = float(binary_to_denary(speed))/50
	realHealth = binary_to_denary(health)
	realStrength = binary_to_denary(strength)
	hunger = binary_to_denary(max_hunger) / 2
	hungerTimer.start()
	set_drain_rate()
	fightTimer.wait_time = float(1) / realSpeed
	
	
	
 
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
		velocity = velocity.lerp(direction * realSpeed , ACCEL * delta)
		
		#adds gravity if not on the floor
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		move_and_slide()
		if isChasing == true and fightTarget != null:
			nav.target_position = fightTarget.position

#allows the creature to jump
func jump(direction):
	velocity.y = JUMP_VELOCITY * speed
	lastKnownDirection = direction


	

	move_and_slide()

#ai will wander around the map, ai needs to pick a location within x distance of the nav mesh, and wander to it, if there isnt anything near by that takes priority
func wanderMode():
	#if it will navigate in a new direction
	if isChasing != true:
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
	if (isReproducing == false) and (foundFood == false) and (isFighting == false) and (isChasing == false) and (isWaiting == false):
		var foodLocation = area.position
		foundFood = true
		nav.target_position = foodLocation





#converts genetics to a usable value
#PROCCESS - FOR EACH NON 0, TAKE ITS I VALUE AND RAISES 2 BY IT, THEN ADDS TO THE TOTAL

func binary_to_denary(binary : String):
	var total = 0
	var binary_split = binary.split()
	for i in range(0, binary_split.size()):
		if binary_split[i] != '0':
			total = total + pow(2,i)
	return total
#used to identify suitable partners
func get_creature_id():
	return self.creature_type
#used to identify whether creatures can reproduce
func get_creature_food_percentage():
	#print(self.hunger)
	#print (self.binary_to_denary(max_hunger))
	return (self.hunger / self.binary_to_denary(max_hunger))
#used to set hunger after actions
func set_hunger(target_hunger):
	self.hunger = target_hunger
	if target_hunger >= binary_to_denary(max_hunger):
		hunger = binary_to_denary(max_hunger)
		if realHealth != binary_to_denary(health):
			realHealth += target_hunger - hunger
#sets the drain rate of hunger, balanced between other genetics
func set_drain_rate():
	var a = binary_to_denary(health)
	var b = binary_to_denary(speed)
	var c = binary_to_denary(strength)
	food_drain_rate = (float((a+b+c)) / 3)/100
#if two creatures of the same type spot eachother, there is a chance they reproduce
func _on_animal_behaviour_body_entered(body):
	if (isChasing != true) and (isFighting != true) and (isWaiting == false):
		if body.is_in_group("Creature"):
			if body.get_creature_id() == self.get_creature_id():
				#print(body.get_creature_food_percentage())
				if ((body.get_creature_food_percentage() >= 0.9) and (self.get_creature_food_percentage() >= 0.9)):
					self.set_hunger(self.hunger / 2)
					body.set_hunger(body.hunger / 2)
					if sex == "male":
						position = body.position + Vector3(1,0,0)
					if sex == "female":
						self.get_parent().create_creature(self,body)
					
					distanceToTravel(cardinalDirection)
#when the hunger timer finishes, the creature will loose an amount of hunger, when this reaches below / equal to zero, they will die / be dequeue'd
func _on_hunger_timer_timeout():
	
	hunger = hunger - food_drain_rate
	
	if hunger <= 0:
		self.queue_free()
#if ai spots another creature, it will either run away (prey behaviour) or attack it (hunter behaviour)
#if it is not hunting, fighting, or waiting (in fight), it will roll between 0 and 100, if it is above a value (script wise 80), then it will target the body and hunt it
func _on_hunt_controller_body_entered(body):
	if (isChasing == false) and (isFighting == false) and (isWaiting == false):
		if body.is_in_group("Creature"):
			if body.isFighting == false:
				var wants_to_kill = randi_range(0,100)
				if wants_to_kill >= 80:
					foundFood = false
					isChasing = true
					fightTarget = body
					nav.target_position = fightTarget.position


#if the fight target has not been engaged, it will abandon hunting and begin navigating again
func _on_hunt_timer_timeout():
	if (fightTarget != null) and (isFighting == false) and (isWaiting == false):
		isChasing = false
		distanceToTravel(cardinalDirection)

#if a body that is attempting to fight the creature, or the creature itself collides with its target, they will begin fighitng, pause all other activities, and start a timer, with a wait time based on their speed
func _on_fight_controller_body_entered(body):
	if isChasing:
		if body.is_in_group("Creature"):
			if (self.fightTarget == body) or (body.fightTarget == self):
				if body.fightTarget != self:
					body.fightForced(self)
				isWaiting = true
				fightTimer.start()

#if another creature enters into combat with this one, it will be forced into defensive combat
func fightForced(body):
	if body != null:
		fightTarget = body
		isWaiting = true
		fightTimer.start()
	

func _on_fight_timer_timeout():
	if fightTarget != null:
		fightTarget.fightTarget = self
		fightTarget.take_damage(realStrength)
	
func take_damage(amount:int):
	realHealth -= amount
	print(realHealth)
	if realHealth <= 0:
		die("killed")
	

func die(how):
	if how == "killed":
		fightTarget.won_Fight(hunger)
	self.queue_free()
	
func won_Fight(hunger_gain):
	isChasing = false
	isFighting = false
	isWaiting = false
	set_hunger(hunger + hunger_gain)
	distanceToTravel(cardinalDirection)
func set_color(color):
	$Body.mesh.material.albedo_color = color 
