extends CanvasLayer

@onready var main = load("res://Scenes/Main.tscn")
@onready var settings = load("res://Scenes/settings_menu.tscn")

func _on_start_pressed():
	get_tree().change_scene_to_packed(main)
	


func _on_settings_pressed():
	get_tree().change_scene_to_packed(settings)


func _on_quit_pressed():
	get_tree().quit()
