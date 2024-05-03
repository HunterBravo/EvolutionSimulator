extends Node3D
@onready var main_menu = load("res://Scenes/start_menu.tscn")
var food_scene = load("res://Scenes/Food.tscn")
var food

var creature_scene = load("res://Scenes/search_ai.tscn")
var creature
@export var creature_count: int = 0
@export var food_count : int = 0
@export var food_max : int = 100
@export var food_value : int = 0
@export var food_respawn_timer: int = 0
#boundaries as grabbed from the boundary positions on the world
var boundaries : Array = [-53,11,-13,30]
var startup = false
@onready var navRegion = $Environment/NavigationRegion3D
@onready var creature_factory = $creatureFactory
@onready var area_checker = $CheckClear
@onready var food_parent = $Food_instances
@onready var food_timer = $Food_Respawn_Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass
	#food.connect("eat",_on_food_ate)
	#food.position = Vector3(-10,1.2,13)
	#add_child(food)
	#food = food_scene.instantiate()
	#food.connect("eat",_on_food_ate)
	#food.position = Vector3(-10,1.2,14)
	#add_child(food)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("ui_accept"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_packed(main_menu)
func _process(delta):
	
	if startup == false:
		startup = true
		generate_world(food_count,creature_count)
		food_timer.wait_time = food_respawn_timer
		food_timer.start()
		
	

func _on_food_ate(foodLoc,animal):
	if animal != null:
		foodLoc.queue_free()
		animal.set_hunger(animal.hunger + 10)
	
	#animal.hunger += 10
	#var maxhunger = creature.binary_to_denary(creature.max_hunger)
	#if creature.hunger >maxhunger:
		#creature.hunger = maxhunger

func add_food():
	food = food_scene.instantiate()
	#picks a random position between the boundaries
	var x = randf_range(boundaries[0],boundaries[1])
	var z = randf_range(boundaries[2],boundaries[3])
	var newpos = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
	area_checker.position = newpos
	while area_checker.has_overlapping_bodies() == true:
		newpos = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
		area_checker.position = newpos
	food.position = newpos
	food.position.y -= 0.5
	food.connect("eat",_on_food_ate)
	area_checker.position = Vector3(-50,-50,-50)
	food_parent.add_child(food)

func create_creature():
	creature = creature_scene.instantiate()
	
	#stat manager
	#sex
	var rand = randi_range(0,1)
	if rand == 0:
		creature.sex = "male"
	else:
		creature.sex = "female"
	print(creature.sex)
	#health
	creature.health = rand_genes()
	#strength
	creature.strength = rand_genes()
	#speed
	creature.speed = rand_genes()
	
	#position manager
	var x = randf_range(boundaries[0],boundaries[1])
	var z = randf_range(boundaries[2],boundaries[3])
	var newpos = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
	area_checker.position = newpos
	while area_checker.has_overlapping_bodies() == true:
		newpos = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
		area_checker.position = newpos
	creature.position = newpos
	area_checker.position = Vector3(-50,-50,-50)
	
	creature_factory.add_child(creature)
	print(creature.get_parent())

func generate_world(food_count,creature_count):
	
	for i in range(0,food_count):
		add_food()
		
		
	for i in range(0,creature_count):
		create_creature()
		
func rand_genes() -> String:
	var dna = ""
	for i in range(0,7):
		var val = randi_range(0,1)
		if val == 0:
			dna = dna + '0'
		else:
			dna = dna + '1'
	return dna




func _on_food_respawn_timer_timeout():
	print("repopulating food")
	var children = food_parent.get_child_count()
	if (children + (children/2)) > food_max:
		children = food_max - (children)
	for i in range(0,children):
		add_food()
	pass # Replace with function body.
