extends Node


const SAVE_FILE = "user://save_file.save"
var g_data = {}

func load_data(): 
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE,FileAccess.READ)
		
		g_data = {
				"color" : 0,
				"strength" : 0,
				"speed" : 0,
				"health" : 0,
				"hunger" : 0
				}
	var file = FileAccess.open(SAVE_FILE,FileAccess.READ)
	g_data = file.get_var()
	file.close()

func _ready():
	load_data()

func save_data():
	var file = FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	file.store_string(g_data)
	file.close()
