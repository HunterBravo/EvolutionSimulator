extends CanvasLayer

@onready var main = load("res://Scenes/Main.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_packed(main)
	
