extends Node3D

var food_scene = load("res://Scenes/Food.tscn")
var food

var creature_scene = load("res://Scenes/search_ai.tscn")
var creature

#boundaries as grabbed from the boundary positions on the world
var boundaries : Array = [-53,11,-13,30]
@onready var navRegion = $Environment/NavigationRegion3D

@onready var area_checker = $CheckClear
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
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		add_food()

func _on_food_ate(foodLoc,animal):
	
	foodLoc.queue_free()

func add_food():
	food = food_scene.instantiate()
	#picks a random position between the boundaries
	var x = randf_range(boundaries[0],boundaries[1])
	var z = randf_range(boundaries[2],boundaries[3])
	food.position = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
	food.position.y -= 0.5
	food.connect("eat",_on_food_ate)
	add_child(food)

func create_creature():
	creature = creature_scene.instantiate()
	var x = randf_range(boundaries[0],boundaries[1])
	var z = randf_range(boundaries[2],boundaries[3])
	var newpos = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
	area_checker.position = newpos
	if area_checker.get_overlapping_bodies() == false:
		creature.position = NavigationServer3D.map_get_closest_point(navRegion.get_navigation_map(),Vector3(x,0,z))
	
	add_child(creature)
	
	pass
