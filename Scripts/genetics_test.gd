extends Node3D

@onready var creatureFactory = $creatureFactory
@onready var ai_one = $creatureFactory/SearchAI
@onready var ai_two = $creatureFactory/SearchAI2

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		ai_one.health = "11111111"
		creatureFactory.create_creature(ai_one,ai_two)
		
	pass
