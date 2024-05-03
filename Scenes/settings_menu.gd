extends CanvasLayer

@onready var sphere = $Node3D/MeshInstance3D
@onready var Strength_lable = $Menu/MarginContainer/VB1/HB4/Strength
@onready var speed_lable = $Menu/MarginContainer/VB1/HB3/Speed
@onready var health_lable = $Menu/MarginContainer/VB1/HB5/Health
@onready var hunger_lable = $Menu/MarginContainer/VB1/HB2/Hunger
@onready var save_lable = $Menu/MarginContainer/VB1/HB6/Save


@onready var main_menu = load("res://Scenes/start_menu.tscn")

var save_path = "user://variable.save"
var save_paths : Array = ["user://variable.save","user://variable.save1","user://variable.save2","user://variable.save3"]
var save_loc = 0
var color
var speed
var strength
var hunger
var health



func _on_color_picker_button_color_changed(color):
	sphere.mesh.material.albedo_color = color
	self.color = color

func _on_strength_slider_value_changed(value):
	var text = "STRENGTH : %s"
	Strength_lable.text = text % value
	strength = value

func _on_speed_slider_value_changed(value):
	var text = "SPEED: %s"
	speed_lable.text = text % value
	speed = value
 
func _on_health_slider_value_changed(value):
	var text = "HEALTH  : %s"
	health_lable.text = text % value
	health = value
func _on_hunger_slider_value_changed(value):
	var text = "HUNGER : %s"
	hunger_lable.text= text % value
	hunger = value
func _on_save_slider_value_changed(value):
	var text = "SAVE : %s"
	save_lable.text = text % value
	save_loc = value

func _on_button_pressed():
	save()

func save():
	var file = FileAccess.open(save_paths[save_loc],FileAccess.WRITE)
	file.store_var(color)
	file.store_var(health)
	file.store_var(strength)
	file.store_var(speed)
	file.store_var(hunger)
	
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_paths[save_loc], FileAccess.READ)
		color = file.get_var()
		health = file.get_var()
		strength = file.get_var()
		speed = file.get_var()
		hunger = file.get_var()
		set_data()
	else:
		print("no data saved")
		
func set_data():
	sphere.mesh.material.albedo_color = color
	var text = "STRENGTH : %s"
	Strength_lable.text = text % strength
	text = "SPEED: %s"
	speed_lable.text = text % speed
	text = "HEALTH  : %s"
	health_lable.text = text % health
	text = "HUNGER : %s"
	hunger_lable.text = text % hunger


func _on_load_pressed():
	load_data()





func _on_back_pressed():
	get_tree().change_scene_to_packed(main_menu)
