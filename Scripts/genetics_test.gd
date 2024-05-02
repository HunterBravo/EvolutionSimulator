extends Node3D

@onready var creatureFactory = $creatureFactory
@onready var ai_one = $creatureFactory/SearchAI
@onready var ai_two = $creatureFactory/SearchAI2

func _ready():
	ai_one.health = "11111111"
	ai_one.sex = "male"
	ai_two.sex = "female"
	pass
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		pass
		#creatureFactory.create_creature(ai_one,ai_two)
		
	pass
